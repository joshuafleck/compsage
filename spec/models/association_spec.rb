require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Association do
  before(:each) do
    @valid_attributes = {
      :name => "Manufacturers Alliance",
      :subdomain => "mfrall",
      :contact_email => "joe@domain.com",
      :password => 'test12',
      :password_confirmation => 'test12'
    }
    @association = Association.new
  end

  it "should have and belong to many organizations" do
    Association.reflect_on_association(:organizations).should_not be_nil
  end

  it "should have many predefined questions" do
    Association.reflect_on_association(:predefined_questions).should_not be_nil
  end

  it "should have many surveys" do
    Association.reflect_on_association(:surveys).should_not be_nil
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
    @association.attributes = @valid_attributes.except(:contact_email)
    @association.should have(3).errors_on(:contact_email)
  end
  
  it 'should require a unique email' do
    @association.attributes = @valid_attributes
    @association.save
    @association1 = Association.new(@valid_attributes.with(:subdomain => "another"))
    @association1.should have(1).errors_on(:contact_email)
  end
  
  it "should not be valid with a email shorter than 5 characters" do
  	@association.attributes = @valid_attributes.with(:contact_email => '1234')
    @association.should have(2).errors_on(:contact_email)
  end
  
  it "should not be valid with a email longer than 100 characters" do
  	@association.attributes = @valid_attributes.with(:contact_email => "0"*101)
    @association.should have(2).errors_on(:contact_email)
  end
  
  it "should not be valid with an invalid email address" do
  	@association.attributes = @valid_attributes.with(:contact_email => '@johnson@.com')
    @association.should have(1).errors_on(:contact_email)
  end
  
  it 'should authenticate an association by owner email and password' do
    @association.attributes = @valid_attributes
    @association.save
    Organization.authenticate(valid_organization_attributes[:email], valid_organization_attributes[:password]).should == @organization
  end
  
end

describe Association, "adding a member" do
  before(:each) do
    @association = Factory(:association)
  end
  
  it "should fail if the member already exists" do
    member = Factory(:organization)
    member.associations << @association
    lambda{ @association.new_member(:email => member.email) }.should raise_error(Association::MemberExists)
  end
  
  it "should locate an existing organization and add it as a member" do
    member = Factory(:organization)
    @association.new_member(:email => member.email).should == member
    member.reload
    member.associations.include?(@association).should be_true
  end
  
  it "should build a new member" do
    member_params = Factory.build(:organization).attributes
    member = @association.new_member(member_params)
    member.should be_valid
    member.associations.include?(@association).should be_true
    member.uninitialized_association_member?.should be_true
    member.pending?.should be_false
    member.activated?.should be_true
  end
  
end

describe Association, "removing a member" do
  before(:each) do
    @association = Factory(:association)
  end
  
  it "should delete an uninitialized member" do
    member = Factory(:uninitialized_association_member)
    member.associations << @association
    lambda{ @association.remove_member(member) }.should change(Organization, :count).by(-1)
  end
  
  it "should dis-associate an intitialized member" do
    member = Factory(:organization)
    member.associations << @association
    lambda{ @association.remove_member(member) }.should change(@association.organizations, :count).by(-1)
  end
  
end
