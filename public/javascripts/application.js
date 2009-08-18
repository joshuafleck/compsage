
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
  
  if(unitsType == 'Annually') {
    if(response < 10000) {
      return "Your response is below minimum wage. Is this correct?";
    }
    if(response > 1000000) {
      return "Your response appears too large. Is this correct?";
    }   
  } 
  else if (unitsType == 'Hourly') {
    if(response < 6.55) {
      return "Your response is below minimum wage. Is this correct?";
    }
    if(response > 500) {
      return "Response appears too large. Is this correct?";
    }  
  }

}

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
  }

  /* Adds a new question at the request of the user from the question form
   */
  this.addNewQuestion = function(e) {
    if(e) {
      e.stop();
    }
    var selectedQuestion = $F(pdqSelect);
    var selectedParentQuestion = $F(followUpSelect);
    var questionParameters = null;

    if(!selectedQuestion)
      return false;

    if(selectedQuestion == "0") {      //The user selected custom question
      if($F('custom_question_text') == '') {
        // don't add the question if the user did not enter any text
        $('custom_question_warning').update('Question text is required');
        return false;
      }
      questionParameters = {'question[text]': $F('custom_question_text'),
                            'question[question_type]': $F('custom_question_response'),
                            'question[parent_question_id]': selectedParentQuestion};

      $('custom_question_text').clear();
      $('custom_question_response').clear();
      $('custom_question_warning').update('');
      $('custom_question_form').blindUp({'duration': 0.5});
    } 
    else if(selectedQuestion != '') {  //The user selected a predefined question
      questionParameters = {'predefined_question_id': selectedQuestion,
                            'parent_question_id': selectedParentQuestion}
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
  }

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
      parentQuestion = questionsById[parentQuestion]
      parentQuestion.followUpQuestions.insertQuestions(questions, null);
    }
  }
  
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
    
  }

  /* Private Functions */
  
  /* Observes the form that the user uses to add questions. */
  function observeNewQuestionForm() {
    addForm.select('input.question_submit').first().observe('click', questionSet.addNewQuestion);
    pdqSelect = addForm.select('#predefined_questions').first();
    pdqSelect.observe('change', customQuestionSelect);
    followUpSelect = addForm.select('#follow_up_question_select').first();
    followUpQuestionsDiv = $('follow_up_question');
  }

  /* Sets up the questions that are in the DOM */
  function initializeQuestions() {
    $(list).immediateDescendants().each(function(li, index) {
      if(index < questionSet.editableQuestions.length)
        return;   // Don't want to re-initialize existing questions.

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

  if(addForm)
    observeNewQuestionForm();

  // Get the list of questions and set up our objects
  initializeQuestions()
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
  }

  /* Cancels editing of this question. Hides the edit fields. */
  this.cancelEdit = function(e) {
    if(e) { e.stop(); }
    editDiv.blindUp({'duration': 0.25});
    displayDiv.blindDown({'duration': 0.25});
  }

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
    })

    new Ajax.Request(questionUri, {
      'method': 'delete'
    });  

  }

  /* Move this question up in the list */
  this.moveUp = function(e) {
    if(e) { e.stop(); }
    if(question.position == 0)
      return;
    
    questionSet.swapQuestionWith(question, 'previous');
    sendPositionUpdate('higher');
  }
  
  /* Move this question down in the list */
  this.moveDown = function(e) {
    if(e) { e.stop(); }
    if(question.position == questionSet.editableQuestions.length - 1)
      return;

    questionSet.swapQuestionWith(question, 'next');
    sendPositionUpdate('lower');
  }

  /* Saves the question, hiding the edit form once finished. */
  this.save = function(e) {
    if(e) { e.stop(); }

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
      if (!e) var e = window.event;
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

  initializeChrome();
  setupObservers();
  this.followUpQuestions = new EditableQuestionSet(followUpList, null, surveyId, questionSet);
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

  if(data_type == 'currency') {
    char_mask = /^\$?(\d*,?)*\.?\d{0,2}$/
    data_template = "$#{number}";
    precision = 2;
    error_message = "Response must be a valid wage or salary, e.g. $10.50, 20,000"
    check_response = checkWageResponse;
  } else if(data_type == 'percent') {
    char_mask = /^\-?\d*\.?\d*\%?$/;
    data_template = "#{number}%";
    check_response = checkPercentResponse;
    error_message = "Response must be a valid percentage, e.g. 25%, 10.2%, -25%"
  } else if(data_type == 'number') {
    char_mask = /^\-?(\d*,?)*\.?\d*$/;
    data_template = "#{number}";
    check_response = checkNumericResponse;
    error_message = "Response must be a valid number, e.g. 3, 23,000, -5.2"
  } else if(data_type == 'text') {
    char_mask = /.*/;
  }

  element.observe('keydown', function(e) {
    //need to check for match here in case of double-keydown
    if(last_valid == "" && e.element().value != '' && e.element().value.match(char_mask))
      last_valid = e.element().value;
  })

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
  })

  //This will review the input to make sure it falls within expected range
  var reviewer = function(e) {
    var clean_value = element.value.replace(/,/g,'').match(/(\-?\d+\.?\d*)|(\-?\.\d+)/);
    var number = parseFloat(clean_value);

    if(precision)
      number = number.toFixed(precision);
    
    if(isNaN(number))
      element.value = "";
    else {
      parts = number.toString().split('.');
      integer_part = parts[0];

      if(parts.length > 1)
        decimal_part = '.' + parts[1];
      else
        decimal_part = '';

      need_comma_regex = /(\d+)(\d{3})/
      while(integer_part.match(need_comma_regex))
        integer_part = integer_part.replace(need_comma_regex, '$1,$2');
      
      var formatted_number = integer_part + decimal_part;
      element.value = data_template.interpolate({'number': formatted_number});

      // sanity range checking will warn users if response is not plausible
      question_id = element.id.match(/(\d+)/)[0];
      $("warning_"+question_id).update(check_response(number, units));
    }

    last_valid = element.value;
  };

  if(data_type != 'text')
    element.observe('change', reviewer);

  if(units)
    units.observe('change',reviewer);
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
