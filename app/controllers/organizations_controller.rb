class OrganizationsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'

  def index
	  
    respond_to do |wants|
      wants.html do
        @organizations = Organization.paginate(:page => params[:page], :order => 'name, location')
      end
      wants.xml do
        @organizations = Organization.find(:all)
        render :xml => @organizations.to_xml 
      end
    end
  end
  
  def show
  
    @organization = Organization.find(params[:id])   
    
    respond_to do |wants|
      wants.html # render template
      wants.xml do
         render :xml => @organization.to_xml
      end
    end
  end
  
  def search   
  
    @search_text = params[:search_text]    
    
    # tack the industry on to the search query to ensure matches with same industry float to the top
    @search_text_with_industry = @search_text + 
      (current_organization.industry.blank? ? "" : " | \"" + current_organization.industry + "\"")
    
    @search_params = {
      :geo => [current_organization.latitude, current_organization.longitude],
      :conditions => {},
      :with => {},
      :match_mode => :extended, # this allows us to use boolean operators in the search query
      :order => '@weight desc, @geodist asc' # sort by relevance, then distance
    }
        
    @organizations = Organization.search @search_text_with_industry, @search_params
       
    respond_to do |wants|
      wants.html # render template
      wants.js do 
        #Scriptaculous auto-completion. Good example can be found here: http://demo.script.aculo.us/ajax/autocompleter_customized
         render :inline => "<%= content_tag(:ul, @organizations.map { |org| content_tag(:li, 
          '<div class=\"organization_name\">'+
            highlight(org.name,@search_text)+(org.location.blank? ? '' : ' | '+org.location)+
          '</div>'+
          '<div class=\"contact_name\"><span class=\"informal\">Contact: '+
          highlight(org.contact_name,@search_text)+
          '</span></div>'+
          '<div class=\"industry\"><span class=\"informal\">Industry: '+
          highlight(org.industry,@search_text)+
          '</span></div>',
          :id => org.id) }) %>"
      end
    end
  end
end
