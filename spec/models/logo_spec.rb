require File.dirname(__FILE__) + '/../spec_helper'

describe Logo do
  before(:each) do
    @logo = Logo.new
  end
  
  it 'should belong to organization' do
    Logo.reflect_on_association(:organization).should_not be_nil
  end
  
  it 'should be invalid without an organization or association' do
    @logo.save
    @logo.should have(1).errors_on(:organization)
    @logo.should have(1).errors_on(:association)
  end

end  
