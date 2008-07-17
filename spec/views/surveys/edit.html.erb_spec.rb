require File.dirname(__FILE__) + '/../../spec_helper'

describe "/surveys/edit" do

  before(:each) do
    assigns[:predefined_questions] = []
    @survey = mock_model(Survey, 
                         :job_title => "Worldy Oceanic Explorer",
                         :description => "Spanish royal family seeking explorer to investigate Western sea.",
                         :end_date => "07/12/1492"
                         )
    assigns[:survey] = @survey
    render 'surveys/edit'
  end
  
  it "should render the edit form" do
    response.should have_tag("form")
  end
  it "should render the surveys questions" do
    pending
  end
  it "should have a submit button" do
    response.should have_tag("input[type=submit]")
  end
  it "should have a cancel link" do
    response.should have_tag("a[href=#{surveys_path}]", "Cancel")
  end

end