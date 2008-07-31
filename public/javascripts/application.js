// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

/**
 * JF: This function will create an AJAX request.
 * This should be used if form_for_remote is not an option.
 * One example is if the request URL is dependent on what the
 * user selects in the form.
 *
 * invitee: the element containing the ID of the invitee
 * target: the html element containing the ID of the target of the invitation
 * url: the path for the request- this should be a template e.g. new Template(surveys/#{replacingID}/invitations)
 * container: the html element to update when the request has completed
 */
function buildAjaxInvitationRequest(invitee,target,url,container) { 
  if($F(target) == '') {
    return false
  }
  new Ajax.Updater(container,url.evaluate({replacingID: $F(target)}), {
    asynchronous:true, 
    evalScripts:true, 
    parameters:Form.serializeElements([invitee])
  }); 
  return false;
};
