class OrganizationsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'

  def index
	  
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
    @search = Ultrasphinx::Search.new(:query => params[:search_text])
    @search.run
    @organizations = @search.results
  end
end
