class OrganizationsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'

  def index
	  @page_title = "Members"
    @organizations = Organization.find(:all)  
    respond_to do |wants|
      wants.html do
        #@organizations = Organization.paginate({:page => params[:page]})
      end
      wants.xml do
        #@organizations = Organization.find(:all)
        render :xml => @organizations.to_xml 
      end
    end
  end
  
  def show
    @organization = Organization.find(params[:id])   
    @page_title = @organization.name
    @breadcrumbs << ["Members", url_for(organizations_path)]    
    respond_to do |wants|
      wants.html # render template
      wants.xml do
         render :xml => @organization.to_xml
      end
    end
  end
  
  def search
    #TODO paginate results
    @page_title = "Search Members"
    @organizations = Organization.find_by_contents(params[:search_text])
  end

end
