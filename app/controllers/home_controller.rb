class HomeController < ApplicationController
  layout :logged_in_or_front_layout
  #class used to serve static files which we want rendered in the site layout.
  def index
    
  end
  
  def show
    render :action => params[:page]
  end
  
  private
  
  def logged_in_or_front_layout
    logged_in? ? "logged_in" : "front"
  end
end
