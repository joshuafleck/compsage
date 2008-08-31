class OrganizationsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'

  def index
	  
    respond_to do |wants|
      wants.html do
        @organizations = Organization.paginate(:page => params[:page])
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
  
    @organizations = Organization.search(
      params[:search_text],
      :geo => [current_organization.latitude, current_organization.longitude]
    )
    
    respond_to do |wants|
      wants.html # render template
      wants.js do #Scriptaculous auto-completion. Good example can be found here: http://demo.script.aculo.us/ajax/autocompleter_customized
         render :inline => "<%= content_tag(:ul, @organizations.map { |org| content_tag(:li, 
          '<div class=\"organization_name\">'+
            org.name+(org.location.blank? ? '' : ' | '+org.location)+
          '</div>'+
          '<div class=\"contact_name\"><span class=\"informal\">Contact: '+
          org.contact_name+
          '</span></div>',
          :id => org.id) }) %>"
      end
    end
  end
end
