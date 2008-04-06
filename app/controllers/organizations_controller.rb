class OrganizationsController < ApplicationController
  before_filter :login_required

	def index
	
    respond_to do |wants|
      wants.html {
				@organizations = Organization.paginate({:page => params[:page]})
      }
      wants.xml { 
				@organizations = Organization.find(:all)
      	render :xml => @organizations.to_xml 
      }
    end
	end
	
	def show
	 @organization = Organization.find(params[:id])
    respond_to do |wants|
      wants.html # render template
      wants.xml { render :xml => @organization.to_xml }
    end
	end
	
	def search
	  #TODO paginate results
		@organizations = Organization.find_by_contents(params[:search_text])
	end

  # render new.rhtml
  #def new
  #end

  #def create
    #cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with 
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    #@organization = Organization.new(params[:organization])
    #@organization.save
    #if @organization.errors.empty?
      #self.current_organization = @organization
      #redirect_back_or_default('/')
      #flash[:notice] = "Thanks for signing up!"
    #else
      #render :action => 'new'
    #end
  #end

end
