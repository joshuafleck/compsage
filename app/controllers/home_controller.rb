#Serves static files which we want rendered in the site layout.
class HomeController < ApplicationController
  layout :logged_in_or_invited_layout
  
  def index
    if logged_in?
      redirect_to surveys_path
    end
    @form_options = Rails.env.production? ? {:protocol => 'https://', :host => 'www.compsage.com', :only_path => false} : {}
  end
  
  def show
    render :action => params[:page]
  end

end
