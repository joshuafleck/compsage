require File.dirname(__FILE__) + '/../../spec_helper'

describe "/messages/show" do

  before(:each) do
    render 'messages/show'
  end

  it "should render the subject"
  it "should render the body"
  it "should render the creation date"
  it "should render a link to the sender's org page"
  it "should render a list of related messages with attibutes and a link for displaying each message"
  it "should render the new message form with prepopulated recipient and subject"

end
