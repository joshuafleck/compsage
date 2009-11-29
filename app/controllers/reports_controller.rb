class ReportsController < ApplicationController
  layout :logged_in_or_invited_layout 
  before_filter :login_or_survey_invitation_required, :must_have_responded_or_sponsored
  
  def show
    @survey         = Survey.with_aasm_state(:finished).find(params[:survey_id])
    @invitations    = @survey.internal_and_external_invitations.not_pending.sort    
    @participations = @survey.participations
    @format         = params[:wage_format] || "Annually"
    
    respond_to do |wants|
      wants.html do
        #check to see if we need to display the invoice         
        if current_organization == @survey.sponsor && @survey.invoice.should_be_delivered? then
          redirect_to survey_billing_path(@survey)
        end
      end
      wants.pdf do 
        set_export_headers
        send_data render_to_string(:layout => false), :disposition => 'attachment', :filename => export_file_name('pdf'), :type => 'application/ms-excel'
      end
      wants.xls do
        set_export_headers
        send_data render_to_string(:layout => false), :disposition => 'attachment', :filename => export_file_name('xls'), :type => 'application/ms-excel'
      end
      wants.doc do
        set_export_headers
        send_data render_to_string(:layout => false), :disposition => 'attachment', :filename => export_file_name('doc'), :type => 'application/ms-excel'
      end
    end
    
  end
  
  # for building charts
  def chart
    @question       = Question.find(params[:question_id])
    @survey         = @question.survey
    @participations = @survey.participations
    
    respond_to do |wants|
      wants.xml { render(:layout => false) }
    end
  end
  
  # email the admins the report of a suspected result along with comment.
  def suspect
    @survey = Survey.with_aasm_state(:finished).find(params[:survey_id])
    Notifier.deliver_report_suspect_results_notification(@survey, params[:comment])
    
    respond_to do |wants|
      wants.js do
        render :text => "Success!"
      end
    end
  end
  
  private
  
  # Filters access users who did not participate in a survey.
  # Redirects to another page if user did not participate.
  # Used as a before filter.
  def must_have_responded_or_sponsored
    @survey = Survey.with_aasm_state(:finished).find(params[:survey_id])
    if (current_organization_or_survey_invitation.participations.find_by_survey_id(@survey.id).nil? &&
      current_organization != @survey.sponsor) 
    then
      flash[:notice] = "The response deadline has passed. You may not view the results unless you have responded to the survey."
      
      if logged_in_from_survey_invitation? then
        redirect_to new_account_path
      else
        redirect_to surveys_path
      end
      
      return false
    end
  end
  
  # Strips out any invalid characters from the filename that would prevent someone 
  #  from saving the file on a Windows machine
  def export_file_name(extension)
    "CompSage Report on #{@survey.job_title.gsub(/[\\\/:\*\?"<>\|]/,' ')}.#{extension}"
  end
  
  # Required for IE6 PDF DL over SSL to allow the browser to cache the report, see issue 299
  def set_export_headers
    response.headers["Cache-Control"] = "cache, must-revalidate"
    response.headers["Pragma"] = "public"
  end
  
end
