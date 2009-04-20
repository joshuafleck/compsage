# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include Exceptions
  include ExceptionNotifiable
  include SslRequirement

  #Use a different layout depending on how the user has entered the application
  def logged_in_or_invited_layout
    logged_in? ? "logged_in" : "front"
  end  
  

  def ssl_required?
    Rails.env.production? && super
  end
end
