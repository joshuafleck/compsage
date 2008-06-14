require File.dirname(__FILE__) + '/../../spec_helper'

describe "report abuse email" do

  before(:each) do
    @offending_organization = mock_model(Organization)
  end
  
  def render_view
    render 'notifier/abuse_report_notification.text.plain.erb'  
  end
  
  it "should contain a discussion id" do
    render_view
    puts response.body
  end
  it "should name the organization responsible"
  it "should contain the discussion attributes"

end
