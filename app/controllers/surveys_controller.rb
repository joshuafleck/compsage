class SurveysController < ApplicationController
  
  before_filter :login_required
  
  def index    
    respond_to do |wants|
      wants.html {
        @running_surveys = current_organization.surveys.open.find(:all, :order => 'created_at DESC')
        @invited_surveys = current_organization.survey_invitations.find(:all, :include => :surveys)
        @completed_surveys = current_organization.surveys.closed.find(:all, :order => 'created_at DESC')
      }
      wants.xml {
        @surveys = current_organization.surveys.find(:all)
        render :xml => @surveys.to_xml
      }
    end
  end

  def show
    @survey = Survey.find(params[:id])
    respond_to do |wants|
      wants.html {        
        if @survey.closed? == :true
          redirect_to survey_report_path(@survey)
        end
      }
      wants.xml{
          render :xml => @survey.to_xml
      }
    end
  end

  def edit
    @survey = current_organization.surveys.open.find(params[:id])
  end
  
  def update
    @survey = current_organization.surveys.open.find(params[:id])
    respond_to do |wants|
       if @survey.update_attributes(params[:survey])
         flash[:notice] = 'Survey was successfully updated.'
         wants.html{
           redirect_to survey_path(@survey) 
           }
       else
         wants.html{ 
           redirect_to edit_survey_path(@survey)
           }
       end
    end
end
  
  def new
    
  end
  
  def create
    @survey = Survey.create!(params[:survey])
    respond_to do |wants|
      if @survey.errors.empty?
        flash[:notice] = "Survey was created successfully!"
        wants.html { redirect_to invitation_url(@survey) }
      else
        wants.html { render :action => "new" }
      end
    end
  end

  def search
    @surveys = Survey.find_by_contents(params[:search_text])
    
    respond_to do |wants|
      wants.html {}
      wants.xml {render :xml => @surveys.to_xml}
    end
  end
  
  def respond
    
  end
  
  def questions
    
  end
  
end