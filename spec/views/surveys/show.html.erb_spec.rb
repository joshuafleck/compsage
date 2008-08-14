require File.dirname(__FILE__) + '/../../spec_helper'

describe "/surveys/show" do

  before(:each) do  
    @owner = mock_model(ExternalSurveyInvitation)
    @current_organization_or_invitation = mock_model(Organization, :name => "TESt", :id => "1")
    template.stub!(:current_organization_or_invitation).and_return(@current_organization_or_invitation)
    template.stub!(:current_organization).and_return(@current_organization_or_invitation)
    
    @invitations = [mock_model(Invitation, :invitee => mock_model(Organization, :name => "TESt", :id => "1"))]
    @external_invitations = [mock_model(ExternalSurveyInvitation, :organization_name => "TESt")]
    
    @survey = mock_model(Survey, :job_title => "Software Engineer", :id => "1", :sponsor => @current_organization_or_invitation, :description => "TEST", :end_date => Time.now, :running? => true, :stalled? => false, :invitations => @invitations, :external_invitations => @external_invitations)
    @discussion_reply = mock_model(Discussion, :responder => @owner, :subject => "Reply Topic", :body => "Reply Body", :id => "2", :is_not_abuse => true, :survey => @survey)
    @discussion_children = [@discussion_reply]
    @discussion_topic = mock_model(Discussion, :all_children => @discussion_children, :responder => @current_organization_or_invitation, :subject => "Root Topic", :body => "Root Body", :id => "1", :survey => @survey)
    @discussions = [@discussion_topic]
    
    @discussions.stub!(:sort).and_return(@discussions)
    @discussion_children.stub!(:sort).and_return(@discussion_children)
    @discussion_children.stub!(:within_abuse_threshold).and_return(@discussion_children)
    
    assigns[:discussions] = @discussions
    assigns[:survey] = @survey
    assigns[:current_organization_or_invitation] = @current_organization_or_invitation
    assigns[:current_organization] = @current_organization_or_invitation
    
    render 'surveys/show'
  end
  
  it "should render the discussion index template" do
    response.should have_tag("#discussions")
  end
  
  it "should render the survey attributes" do
    pending
  end

  it "should have a link to see the results of a complete survey" do
    pending
  end
  
  it "should have the link to the survey questions if the user is invited or an organization" do
    response.should have_tag("a[href=#{survey_questions_path(@survey)}]")
  end
  
  it "should have the a link to edit if user is the survey sponsor" do
    response.should have_tag("a[href=#{edit_survey_path(@survey)}]")
  end
  
  it "should show the invitees" do
    response.should have_tag("#invitations")
  end

end

describe "/surveys/show stalled survey viewed by owner" do

  before(:each) do  
    @owner = mock_model(ExternalSurveyInvitation)
    @current_organization_or_invitation = mock_model(Organization, :name => "TESt", :id => "1")
    template.stub!(:current_organization_or_invitation).and_return(@current_organization_or_invitation)
    template.stub!(:current_organization).and_return(@current_organization_or_invitation)
    
    @survey = mock_model(Survey, :job_title => "Software Engineer", :id => "1", :sponsor => @current_organization_or_invitation, :description => "TEST", :end_date => Time.now, :running? => false, :stalled? => true)
    @discussion_reply = mock_model(Discussion, :responder => @owner, :subject => "Reply Topic", :body => "Reply Body", :id => "2", :is_not_abuse => true, :survey => @survey)
    @discussion_children = [@discussion_reply]
    @discussion_topic = mock_model(Discussion, :all_children => @discussion_children, :responder => @current_organization_or_invitation, :subject => "Root Topic", :body => "Root Body", :id => "1", :survey => @survey)
    @discussions = [@discussion_topic]
    
    @discussions.stub!(:sort).and_return(@discussions)
    @discussion_children.stub!(:sort).and_return(@discussion_children)
    @discussion_children.stub!(:within_abuse_threshold).and_return(@discussion_children)
    
    assigns[:discussions] = @discussions
    assigns[:survey] = @survey
    assigns[:current_organization_or_invitation] = @current_organization_or_invitation
    assigns[:current_organization] = @current_organization_or_invitation
    
    render 'surveys/show'
  end
  
  it "should have the link to rerun the survey" do
    response.should have_tag("form[action=#{rerun_survey_path(@survey)}]")
  end

end
