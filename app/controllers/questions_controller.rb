class QuestionsController < ApplicationController 
  def index
    @questions = current_organization_or_invitation.surveys.open.find(params[:id]).questions
    
    respond_to do |wants|
      wants.html {}
      wants.xml {
         render :xml => @questions.to_xml
      }
    end
  end
  
end
