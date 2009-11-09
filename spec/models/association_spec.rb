require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Association do
  before(:each) do
    @valid_attributes = {
      :name => "Manufacturers Alliance",
      :subdomain => "mfrall",
      :owner_email => "joe@domain.com",
      :password => 'test12',
      :password_confirmation => 'test12',
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
  
  it 'should require an email' do
    @association.attributes = @valid_attributes.except(:owner_email)
    @association.should have(3).errors_on(:owner_email)
  end
  
  it 'should require a unique email' do
    @association.attributes = @valid_attributes
    @association.save
    @association1 = Association.new(@valid_attributes.with(:subdomain => "another"))
    @association1.should have(1).errors_on(:owner_email)
  end
  
  it "should not be valid with a email shorter than 5 characters" do
  	@association.attributes = @valid_attributes.with(:owner_email => '1234')
    @association.should have(2).errors_on(:owner_email)
  end
  
  it "should not be valid with a email longer than 100 characters" do
  	@association.attributes = @valid_attributes.with(:owner_email => "0"*101)
    @association.should have(2).errors_on(:owner_email)
  end
  
  it "should not be valid with an invalid email address" do
  	@association.attributes = @valid_attributes.with(:owner_email => '@johnson@.com')
    @association.should have(1).errors_on(:owner_email)
  end
end
