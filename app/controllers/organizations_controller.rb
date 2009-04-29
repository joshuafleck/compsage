class OrganizationsController < ApplicationController
  before_filter :login_required
  layout 'logged_in'

  def index
	  
    respond_to do |wants|
      wants.xml do
        @organizations = Organization.find(:all)
        render :xml => @organizations.to_xml 
      end
    end
  end
  
  def show 
    @organization = Organization.find(params[:id])   
    if @organization == current_organization then
      redirect_to edit_account_path
    else
      respond_to do |wants|
        wants.html # render template
        wants.xml do
           render :xml => @organization.to_xml
        end
      end
    end
  end
  
  def search   
  
    @search_text = params[:search_text] || ""
    
    @esc_search_text = Riddle.escape(@search_text) 
    
    # this basically says, find everything that matches the query, and everything that matches the query and industry
    # this will give a higher score to organizations with the same industry, but will not allow irrelevant matches
    @search_query = "#{@esc_search_text}* #{@esc_search_text}* | @industry \"#{current_organization.industry}\""    
    
    @search_params = {
      :geo => [current_organization.latitude, current_organization.longitude],
      :conditions => {},
      :with => {},
      :match_mode => @esc_search_text.blank? ? :fullscan : :extended, # this allows us to use boolean operators in the search query, or forego the query all together if the search string was empty
      :order => '@weight desc, @geodist asc' # sort by relevance, then distance
    }
        
    @organizations = Organization.search @search_query, @search_params
       
    respond_to do |wants|
      wants.html # render template
      wants.json do
        render :json => @organizations.to_json(:only => [:name, :location, :id, :contact_name],
                                               :methods => 'name_and_location')
      end
    end
  end
end
