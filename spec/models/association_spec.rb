require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Association do
  before(:each) do
    @valid_attributes = {
      :name => "Manufacturers Alliance",
      :subdomain => "mfrall"
    }
    @association = Association.new
  end

  it "should be valid" do
    @association.attributes = @valid_attributes
    @association.should be_valid
  end

  it "should not be valid without a name" do
    @association.attributes = @valid_attributes.except(:name)
    @association.should_not be_valid
  end

  it "should not be valid without a subdomain" do
    @association.attributes = @valid_attributes.except(:name)
    @association.should_not be_valid
  end
  
  it "should not be valid with a very short subdomain" do
    @association.attributes = @valid_attributes.with(:subdomain => 'ab')
    @association.should_not be_valid
  end

  it "should not be valid with a very long subdomain" do
    @association.attributes = @valid_attributes.with(:subdomain => 'a' * 30)
    @association.should_not be_valid
  end

  it "should not be valid with an invalid subdomain" do
    @association.attributes = @valid_attributes.with(:subdomain => '!@#$!@')
    @association.should_not be_valid
  end
end
