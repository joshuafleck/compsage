require File.dirname(__FILE__) + '/../spec_helper'

module ResponseSpecHelper

  def valid_response_attributes
    {
      :question => mock_model(Question, {}),
      :organization => organization_mock,
      :textual_response => 'The response'
    }
  end
  
end

describe Response do

  include ResponseSpecHelper

  before(:each) do
    @response = Response.new
  end
  
  # test that the associations are here
  
  it 'should be valid' do
  	@response.attributes = valid_response_attributes
  	@response.should be_valid
  end
  
  it 'should belong to an organization' do
  	Response.reflect_on_association(:organization).should_not be_nil
  end
  
  it 'should belong to an external_survey_invitation' do
  	Response.reflect_on_association(:external_survey_invitation).should_not be_nil
  end
  
  it 'should belong to a question' do
  	Response.reflect_on_association(:question).should_not be_nil
  end
  
  it 'should be invalid without a question' do
  	@response.attributes = valid_response_attributes.except(:question)
    @response.should have(1).errors_on(:question)
  end
  
  it 'should be invalid without an organization or external_survey_invitation' do 	
  	@response.attributes = valid_response_attributes.except(:organization,:external_survey_invitation)
    @response.should have(1).errors_on(:external_survey_invitation)
    @response.should have(1).errors_on(:organization)
  end
  
  it 'should be invalid without some response'  do 	
  	@response.attributes = valid_response_attributes.except(:textual_response,:numerical_response)
    @response.should have(1).errors_on(:textual_response)
    @response.should have(1).errors_on(:numerical_response)
  end
  
end


describe Response, "to question with options" do

  include ResponseSpecHelper

  before(:each) do
    @response = Response.new
  end
    
  it "should return a numerical response" do
  	pending
  end
  
end

describe Response, "to question with text based response" do

  include ResponseSpecHelper

  before(:each) do
    @response = Response.new
  end
    
  it "should return a textual response" do
  	pending
  end
  
end

describe Response, "to quesiton with fill-in numerical response" do

  include ResponseSpecHelper

  before(:each) do
    @response = Response.new
  end
    
  it "should return a numerical response" do
  	pending
  end

end
