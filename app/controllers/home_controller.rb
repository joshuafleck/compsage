#Serves static files which we want rendered in the site layout.
class HomeController < ApplicationController
  layout :logged_in_or_invited_layout
  
  def index
    if logged_in?
      redirect_to surveys_path
    end

    @form_options = Rails.env.production? ? {:protocol => 'https://', :host => 'www.compsage.com', :only_path => false} : {}

    #if current_subdomain && current_association then
    #  # Looking for an association page
    #  redirect_to associations_path
    #end
  end
  
  def show
    render :action => params[:page]
  end

  def contact
    @contact_form_submission = ContactFormSubmission.new(params[:contact_form_submission])
    if request.post? then
      if verify_recaptcha(:model => @contact_form_submission, :message => 'You failed to match the captcha') && @contact_form_submission.valid? then
        Notifier.deliver_contact_form_submission(@contact_form_submission)
        render 'contact_success'
      end
    end
  end
end
