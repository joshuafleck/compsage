// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// JF: This function will create an AJAX request.
// This should be used if form_for_remote is not an option.
// One example is if the request URL is dependent on what the
// user selects in the form
function buildAjaxRequest(formToSubmit,dropDownID,requestPath,divToUpdate) { 
  if($F(formToSubmit[dropDownID]) == '') {
    return false
  }
  new Ajax.Updater(divToUpdate,requestPath.evaluate({replacingID: $F(formToSubmit[dropDownID])}), {asynchronous:true, evalScripts:true, parameters:Form.serialize(formToSubmit)}); 
  return false;
};
