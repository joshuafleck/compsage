require File.dirname(__FILE__) + '/../../spec_helper'

describe "/dashboards/show" do

  before(:each) do
    
    # create organizations
    organization_1 = mock_model(Organization)
    organization_1.stub!(:name).and_return("Organization Name")
    
    # create surveys
    survey_1 = mock_model(Survey)
    survey_1.stub!(:sponsor).and_return(organization_1)
    survey_1.stub!(:job_title).and_return('Programmer')
    survey_1.stub!(:end_date).and_return(7.days.from_now)
    survey_1.stub!(:id).and_return(1)
    
    survey_2 = mock_model(Survey)
    survey_2.stub!(:sponsor).and_return(organization_1)
    survey_2.stub!(:job_title).and_return('Janitor')
    survey_2.stub!(:end_date).and_return(2.hours.from_now)
    survey_2.stub!(:id).and_return(2)
    
    # create networks
    network_1 = mock_model(Network)
    network_1.stub!(:name).and_return("Network 1")
    
    network_2 = mock_model(Network)
    network_2.stub!(:name).and_return("Network 2")
    
    # create survey invitations
    survey_invitation_1 = mock_model(SurveyInvitation)
    survey_invitation_1.stub!(:survey).and_return(survey_1)
    survey_invitation_1.stub!(:inviter).and_return(organization_1)
    survey_invitation_1.stub!(:id).and_return(1)
    
    survey_invitation_2 = mock_model(SurveyInvitation)
    survey_invitation_2.stub!(:survey).and_return(survey_2)
    survey_invitation_2.stub!(:inviter).and_return(organization_1)
    survey_invitation_2.stub!(:id).and_return(2)
    
    assigns[:recent_survey_invitations] = [survey_invitation_1, survey_invitation_2]
    
    # create network invitations
    network_invitation_1 = mock_model(NetworkInvitation)
    network_invitation_1.stub!(:network).and_return(network_1)
    network_invitation_1.stub!(:inviter).and_return(organization_1)
    network_invitation_1.stub!(:id).and_return(1)
    
    network_invitation_2 = mock_model(NetworkInvitation)
    network_invitation_2.stub!(:network).and_return(network_2)
    network_invitation_2.stub!(:inviter).and_return(organization_1)
    network_invitation_2.stub!(:id).and_return(2)
    
    assigns[:recent_network_invitations] = [network_invitation_1, network_invitation_2]
    
    # create running surveys
    assigns[:recent_running_surveys] = [survey_1, survey_2]
    
    # create completed surveys
    assigns[:recent_completed_surveys] = [survey_1, survey_2]
    
    render 'dashboards/show'
  end
  
  it "should show links to survey invitations" do
  	response.should have_tag('table#survey_invitations') do
  	  with_tag("tr#survey_invitation_1") do
  	    with_tag("td", "Programmer")
    	  with_tag("td", "Organization Name")
    	  with_tag("td", "7 days")
  	  end

  	  with_tag("tr#survey_invitation_2") do
  	    with_tag("td", "Janitor")
    	  with_tag("td", "Organization Name")
    	  with_tag("td", /2 hours/)
  	  end
	  end
  end
  
  it "should show links to network invitations" do
    response.should have_tag('table#network_invitations') do
  	  with_tag("tr#network_invitation_1") do
  	    with_tag("td", "Network 1")
    	  with_tag("td", "Organization Name")
  	  end

  	  with_tag("tr#network_invitation_2") do
  	    with_tag("td", "Network 2")
    	  with_tag("td", "Organization Name")
  	  end
    end
  end

  it "should show links to your running surveys" do
    response.should have_tag('table#running_surveys') do
  	  with_tag("tr#running_survey_1") do
  	    with_tag("td", "Programmer")
    	  with_tag("td", /7 days/)
  	  end

  	  with_tag("tr#running_survey_2") do
  	    with_tag("td", "Janitor")
    	  with_tag("td", /2 hours/)
  	  end
    end
  end
  
  it "should show links to completed surveys" do
    response.should have_tag('table#completed_surveys') do
  	  with_tag("tr#completed_survey_1") do
  	    with_tag("td", "Programmer")
    	  with_tag("td", "Organization Name")
  	  end

  	  with_tag("tr#completed_survey_2") do
  	    with_tag("td", "Janitor")
    	  with_tag("td", "Organization Name")
  	  end
    end
  end
  
  it "should have a link for creating a new survey" do
  	response.should have_tag('a[href~=/surveys/new]')
  end
  
end
