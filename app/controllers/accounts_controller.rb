class AccountsController < ApplicationController
  before_filter :login_required, :except => [ :new , :create ]
	layout 'logged_in'
	
	def show
	  @page_title = "My Account"
	
	  @organization = current_organization
	  
	  respond_to do |wants|
      wants.html
      wants.xml do
      	render :xml => @organization.to_xml 
      end
    end
	end
	
	def new
	  @page_title = "New Account"
	  
	  @external_invitation = ExternalInvitation.find_by_key(params[:key])
	   
	  @organization = Organization.new
	  
	end
	
	def edit
	  @page_title = "Edit My Account"
	  
  	@organization = current_organization
	end
	
	def create
	  @page_title = "New Account"
	
	  @external_invitation = ExternalInvitation.find_by_key(params[:key])
	  
	  @organization = Organization.new(params[:organization])
	  	  
	  @organization.set_logo(params[:logo])
	    
    if @organization.save then
        
      respond_to do |wants|
        wants.html {         
          flash[:notice] = "Your account was created successfully."
          redirect_to new_session_path() }      
        wants.xml do
          render :status => :created
        end
      end
    else
      respond_to do |wants|
        wants.html do
          render :action => 'new'
        end
        wants.xml do
          render :xml => @organization.errors.to_xml, :status => 422
        end
      end
    end
	end
	
	def update
	  @page_title = "Edit My Account"
	
	  @organization = current_organization  
     
	  @organization.set_logo(params[:logo])
	    
    if @organization.update_attributes(params[:organization]) then
      respond_to do |wants|
        wants.html do
          flash[:notice] = "Your account was updated successfully."
          redirect_to account_path
        end
        wants.xml do
          render :status => :ok
        end
      end
    else
      respond_to do |wants|
        wants.html do
          render :action => 'edit'
        end
        wants.xml do
          render :xml => @organization.errors.to_xml, :status => 422
        end
      end
    end
	end
  
end
