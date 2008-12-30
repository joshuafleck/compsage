# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include Exceptions
  include ExceptionNotifiable
  
  before_filter :make_breadcrumbs
  
  session :session_key => '_shawarma_session_id'
  
  def make_breadcrumbs
    @breadcrumbs = Breadcrumbs.new(["Surveys", url_for(surveys_path)])
  end
  
end
