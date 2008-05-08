require File.dirname(__FILE__) + '/../../spec_helper'

describe "discussions/index" do
  
  before(:each) do
    
    @owner = mock_model(ExternalSurveyInvitation)
    @current_organization_or_invitation = mock_model(Organization)
    template.stub!(:current_organization_or_invitation).and_return(@current_organization_or_invitation)
    
    @discussion_reply = mock_model(Discussion, :responder => @owner, :title => "Reply Topic", :body => "Reply Body", :id => 2)
    @discussion_children = [@discussion_reply]
    @discussion_topic = mock_model(Discussion, :children => @discussion_children, :responder => @current_organization_or_invitation, :title => "Root Topic", :body => "Root Body", :id => "1")
    @discussions = [@discussion_topic]
    
    @discussions.stub!(:sort).and_return(@discussions)
    @discussion_children.stub!(:sort).and_return(@discussion_children)
    
    assigns[:discussions] = @discussions
    assigns[:survey] = mock_model(Survey, :job_title => "Software Engineer", :id => "1")
    assigns[:current_organization_or_invitation] = @current_organization_or_invitation
                
    render 'discussions/index'
  end
  
  it "should render a list of discussions" do
    #puts response.body
    response.should have_tag("#discussions")
  end
  
  it "should have an edit button if the discussion belongs to the user" do
  
  end
  
  it "should have a delete button if the discussion belongs to the user" do
  
  end
  
  it "should render one or more reply buttons" do
  
  end
  
  it "should render one or more report abuse buttons" do
  
  end
  
  #JF- Thinking these specs should not be here if we decide to put discussions on the surveys page
  #it "should list attributes about the discussed survey"
  #it "should have a link to the discussed survey"
end
