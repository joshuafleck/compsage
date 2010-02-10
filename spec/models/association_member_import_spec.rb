require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
# This is not inherited from ActiveRecord, so the spec will be slightly different

describe AssociationMemberImport, "that has a valid CSV input" do
  before(:each) do     
    @importer = AssociationMemberImport.new(valid_importer_params)
    @importer.file = valid_csv_file
    @association = Factory(:association)
    @importer.association = @association
    
  end
  
  it "should find valid members" do
    @importer.import!
    @importer.valid_members.size.should == 5
  end
end

describe AssociationMemberImport, "that has a valid and invalid CSV input" do
  before(:each) do
    @importer = AssociationMemberImport.new(valid_importer_params)
    @importer.file = "Imported Firm, Joe Wilson, joe.wilson@importedfirm.com, 55407, 20, 30
    I cant follow instructions, 1234, asdfasdf"
    @association = Factory(:association)
    @importer.association = @association
    @importer.import!
  end
  
  it "should find a valid member" do
    @importer.valid_members.size.should == 1
  end
  
  it "should find a invalid member" do
    @importer.invalid_members.size.should == 1
  end
end

describe AssociationMemberImport, "that has a valid CSV input and valid headers" do
  before(:each) do
    @importer = AssociationMemberImport.new(valid_importer_params.with(:headers => true))
    @importer.file = "Firm Name, Contact Name, Contact Email, Zip Code, # of Employees, SIC Code / NAICS Code
    Imported Firm, Joe Wilson, joe.wilson@importedfirm.com, 55407, 20, 30
    "
    @association = Factory(:association)
    @importer.association = @association
    @importer.import!
  end
  
  it "should find valid members" do
    @importer.import!
    @importer.valid_members.size.should == 1
  end
end

describe AssociationMemberImport, "that has a valid and invalid CSV input and valid headers" do
  before(:each) do
    @importer = AssociationMemberImport.new(valid_importer_params)
    @importer.file = "Firm Name, Contact Name, Contact Email, Zip Code, # of Employees, SIC Code / NAICS Code
    Imported Firm, Joe Wilson, joe.wilson@importedfirm.com, 55407, 20, 30
    I cant follow instructions, 1234, asdfasdf"
    @association = Factory(:association)
    @importer.association = @association
    @importer.import!
  end
  
  it "should find a valid member" do
    puts @importer.valid_members[0].name
    @importer.valid_members.size.should == 1
  end
  
  it "should find a invalid member" do
    @importer.invalid_members.size.should == 1
  end
end

describe AssociationMemberImport, "that has existing members" do
  
  it "should remove exists organization from association if delete param is set" do
    pending
  end
  
  it "should find existing members by any attribute"
  

  
  describe AssociationMemberImport, "that has uninitialized members" do
    it "should successfully update an existing member from a csv row" do
      pending
    end
    
    it "should delete uninitialized members"
  end
end

describe AssociationMemberImport, "that has a missing CSV file" do
    it "should fail if given bad file"
end

describe AssociationMemberImport, "that has an invalid row" do
  it "should identify the invalid rows"
end
