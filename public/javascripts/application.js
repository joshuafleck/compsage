/* EditableQuestionSet initializes a set of questions that can be edited by the user. This class takes care of
 * observing the new question form, keeping track of all the questions, adding/removing questions from the list, and
 * various other tasks.
 *
 * @list                The DOM list element that holds all the questions. 
 * @addForm             The ID of the add question form.
 * @surveyId            The ID of the survey.
 * @parentQuestionSet   If this question set is a set of follow-up questions, then pass the question set of the parent
 *                      questions in here. Various notifications are passed to the root level question set (such as
 *                      new questions added or deleted). 
 */
function EditableQuestionSet(list, addForm, surveyId, parentQuestionSet) {
  this.editableQuestions = [];

  var questionSet = this;
  var questionsById = {};
  var pdqSelect = null;
  var followUpSelect = null;
  var followUpQuestionDiv = null;

  /* Public Functions */

  /* Remove the specified question from this set. Adjusts the position of the following questions accordingly.
   * @question  The question object to be destroyed.
   */
  this.removeQuestion = function(question) {
    this.editableQuestions = this.editableQuestions.without(question);
    for(i = question.position;i<this.editableQuestions.length;++i) {
      this.editableQuestions[i].position -= 1;
    }
    this.updateFollowups();
    this.restripeQuestions();
  };

  /* Registers the specified question with the root level question set. This allows getting any question, regardless of
   * its position in the DOM or question structure, such as when adding follow-ups by question id. If this question set
   * is not a root level question set, then this merely passes the request up the chain.
   *
   * @question  The question object to register.
   */
  this.registerQuestion = function(question) {
    if(parentQuestionSet) {
      parentQuestionSet.registerQuestion(question);
    }
    else {
      questionsById[question.id] = question;
    }
  };

  /* Update the list of follow-up question select box with the current list of follow-up questions, in the proper
   * order. Only the root level question list is concerned with this operation, so if this isn't a root level
   * question set, pass the request up the chain.
   */
  this.updateFollowups = function() {
    if(parentQuestionSet) { // Send up the chain
      parentQuestionSet.updateFollowups();
    }
    else {                 // Otherwise update the follow-up list.
      for(i = followUpSelect.length - 1; i > 0; i--) {
        followUpSelect.remove(i);
      }

      this.editableQuestions.each(function(question) {
        var ary = question.toOptions();
        ary.each(function(option) {
          followUpSelect.options.add(option);
        });
      });
    }
  };

  /* Swaps the specified question with either the 'previous' question or 'next' question.
   * @question  The question to be swapped.
   * @direction The direction to swap the question, either 'previous' or 'next'.
   */
  this.swapQuestionWith = function(question, direction) {
    var swapPos = null;
    if(direction == 'previous') {
      swapPos = question.position - 1;
    }
    else {
      swapPos = question.position + 1;
    }
    // Swap the array positions
    this.editableQuestions[question.position] = this.editableQuestions[swapPos];
    this.editableQuestions[swapPos] = question;
    
    // Swap the DOM elements
    tmp = new Element('div');
    var first = this.editableQuestions[question.position].listItem.replace(tmp);
    var second = this.editableQuestions[swapPos].listItem.replace(first);
    tmp = tmp.replace(second);

    // Update the questions' positions
    tmp = question.position;
    question.position = swapPos;
    this.editableQuestions[tmp].position = tmp;

    // Update follow-ups with the new order.
    this.updateFollowups();
    this.restripeQuestions();
  };

  /* Adds a new question at the request of the user from the question form
   */
  this.addNewQuestion = function(e) {
    if(e) {
      e.stop();
    }
    var selectedQuestion = $F(pdqSelect);
    var selectedParentQuestion = $F(followUpSelect);
    var questionRequired = $F('question_required')
    var questionParameters = null;

    if(!selectedQuestion){
      return false;
	}

    if(selectedQuestion == "0") {      //The user selected custom question
      if($F('custom_question_text') == '') {
        // don't add the question if the user did not enter any text
        $('custom_question_warning').update('Question text is required');
        return false;
      }
      questionParameters = {'question[text]': $F('custom_question_text'),
                            'question[question_type]': $F('custom_question_response'),
                            'question[required]': questionRequired,
                            'question[parent_question_id]': selectedParentQuestion};

      $('custom_question_text').clear();
      $('custom_question_response').clear();
      $('custom_question_warning').update('');
      $('custom_question_form').blindUp({'duration': 0.5});
    } 
    else if(selectedQuestion != '') {  //The user selected a predefined question
      questionParameters = {'predefined_question_id': selectedQuestion,
                            'required': questionRequired,
                            'parent_question_id': selectedParentQuestion};
    }  
      
    new Ajax.Request('/surveys/' + surveyId + '/questions', {
      'method': 'post',
      parameters: questionParameters,
      'onSuccess' : function(transport) {
        questionSet.insertQuestions(transport.responseText, selectedParentQuestion);
      },
      'onCreate':function() {$('load_indicator').show();},
      'onComplete':function() {$('load_indicator').hide();}
    }); 

    //Reset the select box
    $('predefined_questions').clear();
    $('follow_up_question_select').clear();
    $('question_required').checked = false;
  };

  /* Inserts the specified question under the specified parent question. Called when the server responds to a user's
   * request to add questions.
   * @questions       The questions (in HTML format) to be inserted.
   * @parentQuestion  The parent question of all the questions.
   */
  this.insertQuestions = function(questions, parentQuestion) {
    if(parentQuestion === "" || parentQuestion == null) {
      // Insert the questions into the DOM and initialize the observers and such.
      $(list).insert(questions); 
      initializeQuestions();
    }
    else {
      // Find the question that this is a follow-up to and send the insert request to that question set containing that
      // question's follow-ups.
      parentQuestion = questionsById[parentQuestion];
      parentQuestion.followUpQuestions.insertQuestions(questions, null);
    }
  };
  
  this.restripeQuestions = function() {
    if(parentQuestionSet) {
      parentQuestionSet.restripeQuestions();
      return;
    }
    var i = 0;
    $(list).select('li').each( function(question) {  
      question.className = (i ? 'odd' : 'even');
      i = 1 - i;
    });
    
  };

  /* Private Functions */
  
  /* Observes the form that the user uses to add questions. */
  function observeNewQuestionForm() {
    addForm.select('input.question_submit').first().observe('click', questionSet.addNewQuestion);
    $('custom_question_text').observe('keydown', function(e) {
      if(e.keyCode == Event.KEY_RETURN) {
        e.stop();
        questionSet.addNewQuestion();
      }
    });
    pdqSelect = addForm.select('#predefined_questions').first();
    pdqSelect.observe('change', customQuestionSelect);
    followUpSelect = addForm.select('#follow_up_question_select').first();
    followUpQuestionsDiv = $('follow_up_question');
  }

  /* Sets up the questions that are in the DOM */
  function initializeQuestions() {
    $(list).immediateDescendants().each(function(li, index) {
      if(index < questionSet.editableQuestions.length){
        return;   // Don't want to re-initialize existing questions.
	  }
      var question = new EditableQuestion(questionSet, surveyId, li, index); 
      questionSet.editableQuestions.push(question);
      questionSet.registerQuestion(question);
    });
    questionSet.updateFollowups();
    questionSet.restripeQuestions();
  }

  /* Handles when the user selects a predefined question. This will hide or show the custom question form. */
  function customQuestionSelect(e) {
    if($F(pdqSelect) == "0") {  //The user selected custom question, show the form
      if (!$('custom_question_form').visible()) {
        $('custom_question_form').blindDown({'duration': 0.5});
      }
    } 
    else {                      //The user selected a non-custom question, hide the form
      if ($('custom_question_form').visible()) {
        $('custom_question_form').blindUp({'duration': 0.5});
        $('custom_question_warning').update('');
      }
    }
  }

  if(addForm){
    observeNewQuestionForm();
  }
  // Get the list of questions and set up our objects
  initializeQuestions();
}

/* An editable question is a question that can be edited by the user.
 * @questionSet The question set that this question belongs to.
 * @surveyId    The survey ID this question is belongs to.
 * @listItem    This DOM list element of this question.
 * @position    The position this question is in the question list, starting at 0. This is essentially the index this
 *              question holds in its question set.
 */
function EditableQuestion(questionSet, surveyId, listItem, position) {
  /* Public Attributes */
  this.id = listItem.id.match(/\d+/);
  this.questionSet = questionSet;
  this.surveyId = surveyId;
  this.listItem = listItem;
  this.position = position;
  this.followUpQuestions = null;

  /* Private Attributes */
  var question = this;

  // Buttons and various chrome.
  var cancelButton = null;
  var editButton   = null;
  var deleteButton = null;
  var upButton     = null;
  var downButton   = null;
  var saveButton   = null;
  
  var displayDiv  = null;
  var textDiv     = null;
  var typeDiv     = null;
  var requiredDiv = null;
  var errorDiv    = null;

  var editDiv        = null;
  var textInput      = null;
  var typeSelect     = null;
  var requiredSelect = null;

  var loadIndicator  = null;

  var followUpList = null;

  var questionUri = '/surveys/' + surveyId + '/questions/' + this.id;

  /* Public Functions */

  /* Edit this question. Shows the edit fields. */
  this.edit = function(e) {
    if(e) { e.stop(); }
    displayDiv.blindUp({'duration': 0.25});
    editDiv.blindDown({'duration': 0.25});
  };

  /* Cancels editing of this question. Hides the edit fields. */
  this.cancelEdit = function(e) {
    if(e) { e.stop(); }
    editDiv.blindUp({'duration': 0.25});
    displayDiv.blindDown({'duration': 0.25});
  };

  /* Delete this question. Removes its list item from the DOM, notifies the server of the deletion, and notifies its
   * question set that this question has been deleted.
   */
  this.deleteQuestion = function(e) {
    if(e) { e.stop(); }
    new Effect.Fade(listItem, {'duration': 0.5,
     'afterFinish': function() {
        listItem.remove();
        questionSet.removeQuestion(question);
      }
    });

    new Ajax.Request(questionUri, {
      'method': 'delete'
    });  

  };

  /* Move this question up in the list */
  this.moveUp = function(e) {
    if(e) { e.stop(); }
    if(question.position == 0){
      return;
    }
    questionSet.swapQuestionWith(question, 'previous');
    sendPositionUpdate('higher');
  };
  
  /* Move this question down in the list */
  this.moveDown = function(e) {
    if(e) { e.stop(); }
    if(question.position == questionSet.editableQuestions.length - 1){
      return;
	}
    questionSet.swapQuestionWith(question, 'next');
    sendPositionUpdate('lower');
  };

  /* Saves the question, hiding the edit form once finished. */
  this.save = function(e) {
    if(e) { e.stop(); }
    if(question.valid()) {
      hideErrors();
      new Ajax.Request(questionUri + '.json', {
        'method': 'put',
        'parameters': { 'question[text]': $F(textInput),
                        'question[question_type]': $F(typeSelect),
                        'question[required]': $(requiredSelect).checked },
        'onSuccess' : function(transport) {
          editDiv.blindUp({'duration': 0.25});    
          updateQuestion(transport.responseText.evalJSON());
          displayDiv.blindDown({'duration': 0.25});
        },
        'onCreate': function() {loadIndicator.show();},
        'onComplete': function() {loadIndicator.hide();}
      });
    }
    else {
      showErrors();
    }
  };

  /* Create some DOM option elements. */
  this.toOptions = function() {
    var options = [];
    var option = document.createElement('OPTION');
    option.value = this.id;
    option.text = textDiv.innerHTML;

    options.push(option);
    this.followUpQuestions.editableQuestions.each(function(question) {
      options = options.concat(question.toOptions());
    });

    return options;
  };

  /* Whether or not the form input is valid when editing this question.*/
  this.valid = function() {
    return textInput.value.length > 0
  }

  /* Private Functions */

  /* Selects out the various DOM elements and stores them in private vars for later. */
  function initializeChrome() {
    cancelButton = listItem.select('a.question_cancel').first();
    editButton   = listItem.select('a.question_edit').first();
    deleteButton = listItem.select('a.question_delete').first();
    upButton     = listItem.select('a.question_up').first();
    downButton   = listItem.select('a.question_down').first();
    saveButton   = listItem.select('input.question_save').first();

    displayDiv  = listItem.select('div.question_display').first();
    textDiv     = displayDiv.select('div.question_display_text').first();
    typeDiv     = displayDiv.select('span.question_display_type').first();
    requiredDiv = displayDiv.select('span.question_display_required').first();

    editDiv    = listItem.select('div.question_edit_display').first();
    textInput  = editDiv.select('input.question_text').first();
    typeSelect = editDiv.select('select.question_type_select').first();
    requiredSelect = editDiv.select('input.required_check').first();
    errorDiv   = editDiv.select('div.error_description').first();

    followUpList = listItem.select('ol').first();

    loadIndicator = listItem.select('img.load_indicator').first();
  }

  /* Observes the various question actions */
  function setupObservers() {
    cancelButton.observe('click', question.cancelEdit);
    editButton.observe('click', question.edit);
    deleteButton.observe('click', question.deleteQuestion);
    upButton.observe('click', question.moveUp);
    downButton.observe('click', question.moveDown);
    saveButton.observe('click', question.save);
    listItem.select('input[type=text]').invoke('observe', 'keydown', function(e) {
      if (!e) { var e = window.event; }
      if(e.keyCode==13){
        e.stop();
        question.save();
      }
      return false;
    });
  }

  /* Updates this question with the specified attributes.
   * @newQuestion an object with text, question_type, and required attrs (eg, parsed JSON response from the server).
   */
  function updateQuestion(newQuestion) {
    textDiv.update(newQuestion.text);
    typeDiv.update(newQuestion.question_type);
    requiredDiv.update(newQuestion.required ? 'Required' : '');
  }

  /* Tell the server to update this question's position.
   * @direction The direction to move the question, either up or down.
   */
  function sendPositionUpdate(direction) {
    new Ajax.Request(questionUri + '/move.xml', {
      'method': 'put',
      'parameters': {'direction': direction}
    }); 
  }

  /* Shows the errors div. For now there is only one possible error (Question text is required), but later additional
   * checks can be made.
   */
  function showErrors() {
    errorDiv.update("Question text is required");
    errorDiv.show();
  }

  function hideErrors() {
    errorDiv.update("");
    errorDiv.hide();
  }

  initializeChrome();
  setupObservers();
  this.followUpQuestions = new EditableQuestionSet(followUpList, null, surveyId, questionSet);
}


/* Holds a response to a survey. Will initialize the various observers needed to facilitate responding to a survey.
 * @listElement The list element containing this question.
 */ 
function Response(listElement) {
  var me = this;

  var parentList             = null; 
  var followUpList           = null;
  var container              = null;
  var commentsContainer      = null;
  var commentsFieldContainer = null;
  var commentsField          = null;
  var commentsLink           = null;
  var inputs                 = null;
  var questionInputs         = null;
  var responseType           = null;
  var unitSelect             = null;

  /* Returns the value of this response.
   * TODO support checkboxes, if needed.
   */
  this.value = function() {
    if(responseType == "options") {
      var val = null;
      for(var i = 0; i < questionInputs.length; i++) {
        if(questionInputs[i].checked){
          return $F(questionInputs[i]);
		}
      }
    } else {
      return $F(questionInputs.first());
    }
  };

  /* Allows this question to be answered.
   */
  this.enable = function() {
    inputs.each(function(input) {
      input.removeAttribute('disabled');
    });
  };

  /* Disallows this question from being answered. Clears any input.
   */
  this.disable = function() {
    inputs.each(function(input) {
      if(responseType == 'options') {
        input.checked = false;
      } else {
        input.value = '';
      }
      input.setAttribute('disabled', true);
    });

    me.disableComments();
    me.disableFollowups();
  };

  /* Disallows this question from being commented on. Clears any comments that are entered.
   */
  this.disableComments = function() { 
    if(!me.hasComments()){
      return;
	}

    me.hideComments();
    commentsContainer.hide();
  };

  /* Allows this question to be commented on.
   */
  this.enableComments = function() {
    if(!me.hasComments()){
      return;
	}
    commentsContainer.show();
  };

  /* Shows the comments field.
   */
  this.showComments = function() {
    commentsFieldContainer.show();
    commentsLink.innerHTML = 'Cancel';
  };

  /* Hides the comments field, clearing any input.
   */
  this.hideComments = function() {
    commentsField.value = '';
    commentsFieldContainer.hide();
    commentsLink.innerHTML = 'Add Comment';
  };

  /* Enables follow-ups to this question by firing an event on the follow-up list. Important: if there are no listeners
   * bound to the follow-up list, this will cause an infinite loop due to the event bubbling up to this question's
   * parent list. Then this question will think that it has been asked to be disabled, disable itself, and then tell
   * its follow-up questions to be disabled, repeating the above process ad infinitum. So, make sure that if there is a
   * follow-up questions list, you have observers observing questions:enable/questions:disable before attempting to
   * enable/disable follow-ups.
   */
  this.enableFollowups = function() {
    if(followUpList){
      followUpList.fire('questions:enable');
	}
  };

  /* Disables follow-ups to this question by firing questions:disable. See important information above.
   */
  this.disableFollowups = function() {
    if(followUpList){
      followUpList.fire('questions:disable');
	}
  };

  /* Whether or not this question has been answered.
   */
  this.answered = function() {
    return me.value() != null && me.value() !== '';
  };

  /* Whether or not this question can have comments or not, determined by the presence of the comments div in the
   * response from the server.
   */
  this.hasComments = function() {
    return commentsFieldContainer != null;
  };

  /* Sets up some variables for convenience
   */
  function initializeChrome() {
    parentList        = $(listElement).parentNode;
    followUpList      = $(listElement).select('ol').first();
    container         = $(listElement).select('div').first();
    commentsContainer = $(container).select('div.comments').first();
    if(commentsContainer) {
      commentsFieldContainer = $(commentsContainer).select('div.field').first();
      commentsField          = $(commentsFieldContainer).select('input').first();
      commentsLink           = $(commentsContainer).select('a').first();
    }
    inputs            = $(container).select('input');
    questionInputs    = $(container).select('input:not([id$=comments])');
    unitSelect        = $(container).select('select.units').first();

    if(questionInputs.first().getAttribute('type').match(/checkbox|radio/)) {
      responseType = 'options';
    } else {
      responseType = 'text';
    }

  }

  /* Handles questions events by simply stopping the event and then calling the specified function. The event must be
   * stopped to prevent the event from bubbling up the DOM.
   */
  function questionsEventHandler(func, e) {
    e.stop();
    func.call();
  }

  /* Called when a user has entered valid data.
   */
  function validInputReceived() {
    if(!me.answered()) {
      // User removed their response, so disable comments and follow-ups.
      me.disableFollowups();
      me.disableComments();
    } else {
      // User added a valid response, so enable comments.
      me.enableComments();

      // If the user chose "No" from a yes/no question, disable follow-ups, otherwise, enable them.
      if(responseType == 'options' && questionInputs.length == 2 && me.value() == '1.0') {
        me.disableFollowups();
      } else {
        me.enableFollowups();
      }
    }
  }

  /* Initializes observers needed for various functionality.
   */
  function initializeObservers() {
    // Make sure we do the right thing for enabling/disabling follow-ups.
    parentList.observe('questions:disable', questionsEventHandler.curry(me.disable));
    parentList.observe('questions:enable', questionsEventHandler.curry(me.enable));

    // Call validInputReceived when we've got valid input.
    if(responseType == "options") {
      questionInputs.each(function(input) {
        input.observe('click', validInputReceived);
      });
    } else {
      questionInputs.first().observe('question:validinput', validInputReceived);
    }

    // Observe the comments link to show/hide comments if we have comments.
    if(me.hasComments()) {
      commentsLink.observe('click', function(e) {
        e.stop();
        if(commentsLink.innerHTML == 'Cancel'){
          me.hideComments();
		}
        else {
          me.showComments();
		}
      });
    }

    // Observe the unit selects to set all the units to the same thing if we have units.
    if(unitSelect) {
      unitSelect.observe('change', function(e) {
        var value = e.target.value;
        var css_class = e.target.className;
        $$('select.units').each(function(select) {
          if(select.value == '' && select.className == css_class) {
            select.value = value;
          }
        });
      });
    }
  }
  
  /* Creates new responses for all the follow-up questions (Assuming there are any).
   */
  function initializeFollowups() {
    if(followUpList) {
      $(followUpList).childElements().each(function(li) {
        new Response(li);
      });
    }
  }

  /* Does the initial setup required for the question form. This includes:
   * * Setting the comments link text to cancel (it is hidden so users without javascript don't get confused)
   * * Disabling/Enabling both comments/follow-ups depending on the situation.
   * * Initializing the input masks if needed.
   */
  function initialSetup() {
    if(me.hasComments()){
      commentsLink.innerHTML = 'Cancel';
	}
    
    if(!me.answered()) {
      // Haven't answered the question, so, can't add comments and can't add follow-ups.
      me.disableComments();
      me.disableFollowups();
    } else {
      if(me.hasComments() && commentsField.value == '') {
        me.hideComments();
      }
    }
    if(responseType == 'text') {
      // Set up our masks if needed for the question type.
      var field = questionInputs.first();
      switch(field.className) {
        case "WageResponse":
        case "BaseWageResponse":
          new inputMask(field, 'currency', unitSelect); 
          break;
        case "NumericalResponse":
          new inputMask(field, 'number'); 
          break;
        case "PercentResponse":
          new inputMask(field, 'percent'); 
          break;
        case "TextualResponse":
          new inputMask(field, 'text'); 
          break;
      }
    }
  }

  initializeChrome();
  initializeObservers();
  initializeFollowups();
  initialSetup();
}

/*
 * inputMask creates a new mask object that will only allow certain inputs. Currently supports only currency, percent,
 * and plain number.
 * @element Form element to observe.
 * @data_type Expected data type for the form element. Must be one of 'currency', 'percent', or 'number'
 * @units Form element containing units for currency questions (optional parameter)
 */
function inputMask(element, data_type, units) {
  var element = element;	
  var data_type = data_type;
  var char_mask	= /.*/;
  var last_valid = "";
  var data_template = "";	
  var precision = null;
  var check_response = null;
  var error_message = "";
  var units = units;

  /**
   * This will sanity check a percentage response
   * @response The numeric response entered by the user
   */
  function checkPercentResponse(response) {
    if(response < 1 && response > -1 && response != 0) {
      return "Percentages should be entered in whole percents. Is this correct?";
    }  
  }

  /**
   * This will sanity check a numeric response
   * @response The numeric response entered by the user
   */
  function checkNumericResponse(response) {
    if(response < 0) {
      return "Your response is negative. Is this correct?";
    }
  }

  /**
   * This will sanity check a wage response
   * @response The numeric response entered by the user
   * @units The units dropdown element.
   */
  function checkWageResponse(response, units) {
    var unitsType = units.options[units.selectedIndex].text;
    
    var tooLargeMessage = "Your response appears too large. Is this correct?";
    var minimumWageMessage = "Your response is below minimum wage. Is this correct?";
    
    if(unitsType == 'Annually') {
      if(response < 10000) {
        return minimumWageMessage;
      }
      if(response > 1000000) {
        return tooLargeMessage;
      }   
    } 
    else if (unitsType == 'Hourly') {
      if(response < 6.55) {
        return minimumWageMessage;
      }
      if(response > 500) {
        return tooLargeMessage;
      }  
    }

  }

  if(data_type == 'currency') {
    char_mask = /^\$?(\d*,?)*\.?\d{0,2}$/;
    data_template = "$#{number}";
    precision = 2;
    error_message = "Response must be a valid wage or salary, e.g. $10.50, 20,000";
    check_response = checkWageResponse;
  } else if(data_type == 'percent') {
    char_mask = /^\-?\d*\.?\d*\%?$/;
    data_template = "#{number}%";
    check_response = checkPercentResponse;
    error_message = "Response must be a valid percentage, e.g. 25%, 10.2%, -25%";
  } else if(data_type == 'number') {
    char_mask = /^\-?(\d*,?)*\.?\d*$/;
    data_template = "#{number}";
    check_response = checkNumericResponse;
    error_message = "Response must be a valid number, e.g. 3, 23,000, -5.2";
  } else if(data_type == 'text') {
    char_mask = /.*/;
  }

  element.observe('keydown', function(e) {
    //need to check for match here in case of double-keydown
    if(last_valid == "" && e.element().value != '' && e.element().value.match(char_mask)){
      last_valid = e.element().value;
	}
  });

  element.observe('keyup', function(e) {
    question_id = e.element().id.match(/(\d+)/)[0];
    var new_value = e.element().value;
    if(!new_value.match(char_mask)) {
      e.element().value = last_valid;
      $("warning_"+question_id).update(error_message);
    } else {
      last_valid = e.element().value;
      $("warning_"+question_id).update('');
      element.fire('question:validinput');
    }
  });

  //This will review the input to make sure it falls within expected range
  var reviewer = function(e) {
    var clean_value = element.value.replace(/,/g,'').match(/(\-?\d+\.?\d*)|(\-?\.\d+)/);
    var number = parseFloat(clean_value);

    if(precision){
      number = number.toFixed(precision);
    }
    if(isNaN(number)){
      element.value = "";
	  }
    else {
      parts = number.toString().split('.');
      integer_part = parts[0];

      if(parts.length > 1){
        decimal_part = '.' + parts[1];
	    }
      else {
        decimal_part = '';
      }
      need_comma_regex = /(\d+)(\d{3})/;
      while(integer_part.match(need_comma_regex)){
        integer_part = integer_part.replace(need_comma_regex, '$1,$2');
      }
      var formatted_number = integer_part + decimal_part;
      element.value = data_template.interpolate({'number': formatted_number});

      // sanity range checking will warn users if response is not plausible
      question_id = element.id.match(/(\d+)/)[0];
      $("warning_"+question_id).update(check_response(number, units));
    }

    last_valid = element.value;
  };

  if(data_type != 'text'){
    element.observe('change', reviewer);
  }
  if(units){
    units.observe('change',reviewer);
  }
}

/* Invitation List object. Should be initialized on the survey invitation page. Requires the fast autocompleter to
 * function, so make sure that is included as well.
 * @survey_id The ID of the survey the invite list is for.
 */
function InviteList(survey_id) {
  
  this.addInvitationToList = function(invitation_id, invitation_display, organization_id) {
    $('external_invitation_organization_name').value = '';
    $('external_invitation_email').value = '';

    var newListElement = new Element('li', {'id': 'invitation_' + invitation_id});
    var removeLink = new Element('a', {'href':'#', 'class':'remove'});
    removeLink.insert('<img src="/images/remove_button.gif" />');
    removeLink.observe('click', removeInvitation.curry(invitation_id));
    newListElement.insert(removeLink);

    if(organization_id){
      newListElement.insert('<a href="/organizations/' + organization_id + '">' + invitation_display + '</a>');
    }
    else{
      newListElement.insert(invitation_display);
    }

    $('invitations').insert(newListElement);
    newListElement.hide();
    newListElement.appear({'duration':0.5});
  };

  function initializeObservers() {
    var cachedBackend = new Autocompleter.Cache(liveOrganizationSearch,{'choices': 10, 'dataToQueryParam': function(data) {return data.name;}});
    var cachedLookup = cachedBackend.lookup.bind(cachedBackend);

    new Autocompleter.Json('external_invitation_organization_name', 'search_results', cachedLookup, {
      'list_generator': function(choices) {
        var list = new Element('ul');

        choices.each(function(choice) {
          var li = new Element('li');
          li.insert('<div class="actions"><a href="#"><img src="/images/add_invitation_button.gif" /></a></div>' + 
            '<div class="name">' + choice.name + '</div>');
          if(choice.location) {
            li.insert('<div class="location description_box">Location: ' + choice.location + '</div>');
          }
          li.data = choice;
          list.insert(li);
        });

        return list;
        },
      'minChars': 2,
      'delay': 0.1,
      'updateElement': function(li) {
        addInvitation(li.data);
      }
    });

    $$('#networks > li').each(function(network_li) {
      var network_id = network_li.id.match(/\d+/)[0];
      var expand_link = network_li.select('a.expand_network').first();
      var collapse_link = network_li.select('a.collapse_network').first();

      expand_link.observe('click', function(e) {
        e.stop();
        $('network_' + network_id + '_members').show(); 
        this.hide();
      });

      network_li.select('a.collapse_network').first().observe('click', function(e) {
        e.stop();
        $('network_' + network_id + '_members').hide(); 
        expand_link.show();
      });

      network_li.select('a.invite').first().observe('click', inviteNetwork.curry(network_id));
    });

    $('invitation_form').observe('submit', addInvitationByForm);

    $$('ul#invitations > li').each(function(invitation_li) {
      var id_match = invitation_li.id.match(/\d+/);
      var invitation_id = '';
      if(id_match == null){
        return;
      }
      else{
        invitation_id = id_match[0];
      }

      var remove_link = invitation_li.select('a.remove').first();
      if(remove_link){
        remove_link.observe('click', removeInvitation.curry(invitation_id));
      }
    });
    
    //observe the remove all link
    $('remove_all_invitations').observe('click', removeAllInvitations);
    
    //test to see if the association integration form is present, it won't be if we are not an association member
    if( $('organization_name') ) {
      //observer for the association integration form
      $('organization_name').observe('keyup', function(e){
        //filter if more than two, or delete was pressed
        if($('organization_name').value.length > 2 || e.keyCode == 8){
          liveAssociationFilter();
        }
      });
      $('organization_location').observe('change', liveAssociationFilter);
      $('organization_size').observe('change', liveAssociationFilter);
      
      //observe invite button click for multi-select invitations
      $('invite_link').observe('click', submitMultipleInvitations);  
    
     /* This is a bit of a hack. The initial naics event is fired before the live search 
      * observer is bound. This ensures that the industry filter is applied on load
      */
      var naics = $('organization_naics_code');    
      naics.observe("naics:updated", liveAssociationFilter);
      if(naics.value > 0) {
        naics.fire("naics:updated");
      }
                
    }
    
    //observers for each add invitation link
    $$('ul#association_organizations > li').each(function(org_li){
      var id_match = org_li.id.match(/\d+/);
      var invite_link = org_li.select('a').first();
      invite_link.observe('click', addAssociationInvitation.curry(id_match));
    });

  }
  
  /* This function handles the invite link click for
     the association pick list. It collects the checked
     organizations and sends an ajax request to add the invites. */
  function submitMultipleInvitations(e){
    e.stop();
    
    var organizations = new Array();
    $$('ul#association_organizations > li').each(function(org_li){
      var id_match = org_li.id.match(/\d+/);
      if(org_li.visible()){
        organizations.push(id_match);
      }
    });
    
    //If there are more than 15 invitations, double check that this was intentional.
    if(organizations.length > 15) {
      if(confirm('You are about to invite ' + organizations.length + 
                   'firms. Are you sure you want to do this?')){
       //ajax request to invite array of orgs
       addAssociationInvitations(organizations);
      }
    }
    return;
  }
  
  /*
   * Passed along the organization ID to be invited and
     stops the event to prevent
     @ organization_id - the organization id to invite.
   */
  function addAssociationInvitation(organization_id, e){
    e.stop();
    addInvitationByID(organization_id);
  }
  
  /*
    event handler for association live search, filters the list based 
    on the strings in the 'organization_name' and 'organization_location'
    inputs and submits it to Thinking Sphinx to search.
  */
  function liveAssociationFilter(){
    var value = $('organization_name').value
    //if value length is less than 3, set to blank so it is ignored.
    value = value.length > 2 ? value : "";
    var distance = $('organization_location').value;
    var size = $('organization_size').value;
    var naics = $('organization_naics_code').value;
    naics = naics > 0 ? naics : ""; // sometimes comes through as 'undefined', prevents this from being sent to the server
    
    if(value != ""  || distance != "" || size != "" || naics != ""){
      new Ajax.Request('/organizations/search_for_association_list.json', {
        'method': 'get',
        'parameters': {'search_text': value, 'distance': distance,
                        'size': size, 'naics': naics},
        'requestHeaders': {'Accept':'application/json'},
        'onSuccess': function(transport) {
          toggleOrganizations(transport.responseText.evalJSON());
        },
        'onCreate': function() {
          $('invite_load_indicator').show();
        },
        'onComplete': function() {
          $('invite_load_indicator').hide();
        }
      });
    }
    else {
      $$('ul#association_organizations > li').each(function(org_li){
        org_li.show();
      });
    }
  }
  
  /*
   * Shows or hides the organizations depending upon the passed list.
     @ organizations - a list of organizations to show.
   */
  function toggleOrganizations(organizations) {
    $$('ul#association_organizations > li').each(function(organization_li){
      organization_li.hide();
    });
    
    organizations.each(function(organization) {
      //invited orgs are not in the list, so do not toggle.
      if($("organization_" + organization.id)){
        $("organization_" + organization.id).show();
      }
    });
  }

  /*
   * This will send an ajax request to the server with the search text
   */
  function liveOrganizationSearch(value, suggest) {
    new Ajax.Request('/organizations/search.json', {
      'method': 'get',
      'parameters': {'search_text': value},
      'requestHeaders': {'Accept':'application/json'},
      'onSuccess': function(transport) {
        suggest(transport.responseText.evalJSON());
      },
      'onCreate': function() {
        $('live_load_indicator').show();
      },
      'onComplete': function() {
        $('live_load_indicator').hide();
      }
    });
  }

  /* Sends the ajax request to invite an array of organizations.
      @organizations - a JavaScript array of IDs.
   */
  function addAssociationInvitations(organizations) {
    new Ajax.Request('/surveys/' + survey_id + '/invitations/create_for_association', {
      'method': 'post',
      'parameters': {'organizations': Object.toJSON(organizations)},
      'onCreate': function() {$('invite_load_indicator').show();},
      'onComplete': function() {$('invite_load_indicator').hide();}
    });
  }

  function addInvitationByForm(e) {
    e.stop();
    var org_name = $F('external_invitation_organization_name');
    new Ajax.Request('/surveys/' + survey_id + '/invitations', {
      'method': 'post',
      'parameters': $('invitation_form').serialize(),
      'onCreate': function() {$('submit_load_indicator').show();},
      'onComplete': function() {$('submit_load_indicator').hide();}
    });
  }

  /* Function to allow Polymorphism of the add invitation function. Takes
     the organization and passed on only the needed params (id).
     
     @organization -  an object that contains an organization id.
   */
  function addInvitation(organization) {
    addInvitationByID(organization.id);
  }

  /* Sends the ajax request to invite the specified organization.
  
    @organization_id -  the ID of the organization to invite.
   */
  function addInvitationByID(organization_id) {
    new Ajax.Request('/surveys/' + survey_id + '/invitations', {
      'method': 'post',
      'parameters': {'organization_id': organization_id},
      'onCreate': function() {$('submit_load_indicator').show();},
      'onComplete': function() {$('submit_load_indicator').hide();}
    });
  }
  

  function removeInvitation(invitation_id, e) {
    e.stop();
    new Effect.Fade('invitation_' + invitation_id, {
      'duration': 0.5,
      'afterFinish': function() {
        $('invitation_' + invitation_id).remove();
      }
    });

    new Ajax.Request('/surveys/' + survey_id + '/invitations/' + invitation_id, {
      'method': 'delete'
    });
  }
  
  function removeAllInvitations(e){
    e.stop();
    if(confirm('This will remove all pending invitations. Are you sure you want to do this?')){
      new Ajax.Request('/surveys/' + survey_id + '/invitations/destroy_all.json', {
          'method': 'post',
          'requestHeaders': {'Accept':'application/json'},
          'onSuccess': function(transport) {
            removeInvitationsFromPage(transport.responseText.evalJSON());
          }
      });
    }
  }
  
  function removeInvitationsFromPage(invitations){
    invitations.each(function(invitation){
      $('invitation_' + invitation.id).remove();
    });
  }

  function inviteNetwork(network_id, e) {
    e.stop();
    new Ajax.Request('/surveys/' + survey_id + '/invitations/create_for_network', {
      'method': 'post',
      'parameters': {'network_id': network_id},
      'onCreate': function() {$('load_indicator_' + network_id).show();$('network_' + network_id + '_invite').hide();},
      'onComplete': function() {$('load_indicator_' + network_id).hide();$('network_' + network_id + '_invite').show();}
    });
  }

  initializeObservers();
}

/**
 * Logic for browsing the NAICS taxonomy
 * @param selected_code The code for the current node
 */
function NaicsClassificationList(selected_code) {
  // Whether or not to show ancestors in the list.
  this.showAncestors = true;

  // Make sure we always have a reference to this class
  var my = this;

  // Keep track of the ancestors, as we need them in order to 'go back' up the taxonomy
  var ancestors = $A();

  /**
   * Will initialize the naics list, and observe the links for drilling up/down
   */
  function initializeObservers() {
    my.retrieveAncestorAndChildNaicsClassifications(selected_code);

    $('naics_classification_back').observe('click', goBack);
    $('naics_select').observe('change', drillDeeper);
    
  };

  /**
   * Will retrieve the list of child and ancestor nodes from the server, and update the UI with that information
   * @param currentCode A naics code, or null, if no naics code was selected.
   */
  this.retrieveAncestorAndChildNaicsClassifications = function(currentCode) {
  
    // Keep track of the selected node here, this is what is passed to the model on submit
    var naics_classification = $('organization_naics_code');
    naics_classification.value = currentCode;
    var event = naics_classification.fire("naics:updated");
  
    new Ajax.Request('/naics_classifications/children_and_ancestors.json', {
      'method': 'get',
      'parameters': {'id': currentCode},
      'requestHeaders': {'Accept':'application/json'},
      'onSuccess': function(transport) {
        var children = transport.responseText.evalJSON().children.evalJSON();
        my.ancestors = transport.responseText.evalJSON().ancestors.evalJSON();
            
        updateChildNaicsClassifications(children);
        updateAncestorNaicsClassifications();
      },
      'onCreate': function() {
        $('live_load_indicator').show();
      },
      'onComplete': function() {
        $('live_load_indicator').hide();
      }
    });
  };
    
  /**
   * Rebuild the naics select box with a new set of nodes
   * @param children An array of naics nodes
   */
  function updateChildNaicsClassifications(children) {

    var child_naics_classifications = $('naics_select');
        
    // Remove the existing options
    while(child_naics_classifications.options.length > 0){child_naics_classifications.remove(0);}

    // Add a default option
    var blankChildOption = document.createElement("option");
    blankChildOption.text = $('organization_naics_code').value > 0 ? "More Specific..." : "Select an industry" ;
    blankChildOption.value = null;
    try {
      child_naics_classifications.add(blankChildOption, null);
    } catch(ex) {
      child_naics_classifications.add(blankChildOption);
    }
    
    // Create options for the child nodes
    for(var i=0; i<children.size(); i++) {
      var child = children[i];
      var childOption = document.createElement("option");
      childOption.text = child.display_code + ": " + child.description;
      childOption.value = child.code;
      try {
        child_naics_classifications.add(childOption, null);
      } catch(ex) {
        child_naics_classifications.add(childOption);
      }
    }
    
    // Hide the select box if there are no more children
    if(children.size() == 0) {
      $('naics_select').hide();
    } else {
      $('naics_select').show();
    }    
  };  
  
  /**
   * Rebuilds the naics classification ancestor list
   */
  function updateAncestorNaicsClassifications() {
    var ancestorsUL = $('naics_classification_ancestors');
    
    // Remove the existing options
    ancestorsUL.innerHTML = '';
    
    var start = 0;

    if(my.ancestors.length > 0 && !my.showAncestors)
      start = my.ancestors.length - 1;

    // Create options for the child nodes
    for(var i=start; i<my.ancestors.size(); i++) {
      var ancestor = my.ancestors[i];
      var ancestorLI = document.createElement("li");
      var description = ancestor.display_code + ": " + ancestor.description;
      // The selected node should be bold to signify its selection
      if(i == my.ancestors.size() - 1 && my.showAncestors) {
        ancestorLI.className = 'selected';
      } 

      ancestorLI.innerHTML = description;
      ancestorsUL.insert(ancestorLI, { 'position' : 'last'});
    }
    
    // Hide the 'go back' link if we are at the level 1 option
    // Hide the ancestors list if no ancestors are present (silly hack for IE6, otherwise there is a big gap in the form)
    if(my.ancestors.size() == 0) {
      $('naics_classification_back').hide();
      ancestorsUL.hide();
    } else {
      $('naics_classification_back').show();
      ancestorsUL.show();
    }
  };   
  
  /**
   * Drills into the selected taxonomy node
   */
  function drillDeeper(e) {
    e.stop();
    var child_naics_classifications = $('naics_select');
    
    var code = child_naics_classifications.options[child_naics_classifications.selectedIndex].value;
    
    if(code) {
      my.retrieveAncestorAndChildNaicsClassifications(code);
    }
  }
  
  /**
   * Goes up the taxonomy tree one node
   */  
  function goBack(e) {
    e.stop();
    var parentNodeIndex = 2;
    var parentOfSelectedNode = my.ancestors[my.ancestors.size() - parentNodeIndex];
    
    // Find an ancestor with at least 2 children, since we do not show nodes with 1 child
    while(parentOfSelectedNode && parentOfSelectedNode.children_count == 1) {
      parentNodeIndex++;
      parentOfSelectedNode = my.ancestors[my.ancestors.size() - parentNodeIndex];
    }
    
    var parentCodeOfSelectedNode = null;
    if(parentOfSelectedNode) {
      parentCodeOfSelectedNode = parentOfSelectedNode.code
    }
    
    my.retrieveAncestorAndChildNaicsClassifications(parentCodeOfSelectedNode);    

  }

  initializeObservers();
}

/*
 * This will add observers to all form inputs that will call the specified method when enter is pushed
 * @form the form
 * @toCall the function that will be called
 */
function callFunctionOnEnterForm(f,toCall) {
  var inputs = f.select('input');
  inputs.each(function(s) {
    s.observe('keydown', callFunctionOnEnter.curry(toCall));
  });
}

/*
 * This will capture the enter key and call the provided function
 * @toCall the function to call
 * @e the event
 */
function callFunctionOnEnter(toCall,e) {
  if(e.keyCode == Event.KEY_RETURN) {
    toCall.call();
  }
}

/*
 * This will make an anynchronous request to have an invitation created 
 * @organization the organization id of the invitee
 */
function sendInvitation(organization,path) {
  e = this;
	new Ajax.Request(path+'/'+$F(this)+'/invitations', {
		'method': 'post',
		'parameters': 'invite_organization['+organization+'][included]=1',
		'requestHeaders': {'Accept':'text/javascript'},
		'onSuccess': function(transport) {
			showInvitationResults(transport.responseText,e,organization);
		}
	});  
}

/**
 * This will render the response of the invitation request 
 * @response the response from the server
 * @elem the select element to be reset
 * @organization the organization id of the invitee
 */
function showInvitationResults(response,elem,organization) {
  elem.value = '';
  $('organization_'+organization+'_response').update(response);
}

/**
 * This will return true if the field is an email address, and false otherwise
 * @email the email string

 */
function isValidEmail(email) {
  var filter = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
  return filter.test(email);
}
