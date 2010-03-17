require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
# This is not inherited from ActiveRecord, so the spec will be slightly different

describe AssociationMemberImport, "that has a valid CSV input" do
  before(:each) do     
    @importer = AssociationMemberImport.new(valid_importer_params)
    @importer.file = valid_csv_file
    @association = Factory(:association)
    @importer.association = @association
    @importer.import!
  end
  
  it "should find valid members" do
    @importer.valid_members.size.should == 5
  end
  
  it "should add the member to the association" do
    @association.organizations.size.should == @importer.valid_members.size
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
    @importer = AssociationMemberImport.new(valid_importer_params.with('headers'=> true))
    @importer.file = "Firm Name, Contact Name, Contact Email, Zip Code, # of Employees, SIC Code / NAICS Code
    Imported Firm, Joe Wilson, joe.wilson@importedfirm.com, 55407, 20, 30
    "
    @association = Factory(:association)
    @importer.association = @association
    @importer.import!
  end
  
  it "should find valid members" do
    @importer.valid_members.size.should == 1
  end
end

describe AssociationMemberImport, "that has a valid and invalid CSV input and valid headers" do
  before(:each) do
    @importer = AssociationMemberImport.new(valid_importer_params.with('headers' => true))
    @importer.file = "Firm Name, Contact Name, Contact Email, Zip Code, # of Employees, SIC Code / NAICS Code
    Imported Firm, Joe Wilson, joe.wilson@importedfirm.com, 55407, 20, 30
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

describe AssociationMemberImport, "that has existing members when the delete param" do
  before(:each) do
    @importer = AssociationMemberImport.new(valid_importer_params.with('destroy' => true))
    @importer.file = valid_csv_file
    @association = Factory(:association)
    @importer.association = @association
    
    @org1 = Factory(:organization, :email => "josh@fleck.com", :name => "Imported Firm 2", :contact_name => "Josh Fleck")
    @org2 = Factory(:organization, :email => "gone@gone.com", :name => "Delete this!", :contact_name => "Or else")
    @uiorg1 = Factory( :uninitialized_association_member, 
                      :email => "delete@me.com", 
                      :name => "I should dissapear", 
                      :contact_name => "From this app")
    
    @association.organizations += [@org1, @org2, @uiorg1]
    
    @importer.import!
  end
  
  it "should remove existing organization from association if they aren't on the list" do
    @importer.deleted_members.size.should == 2
    lambda { @association.organizations.find(@org2.id) }.should raise_error(ActiveRecord::RecordNotFound)
    lambda { Organization.find(@org2.id) }.should_not raise_error(ActiveRecord::RecordNotFound)
  end
  
  it "should not remove organizations on the list" do
    lambda { @association.organizations.find(@org1.id) }.should_not raise_error(ActiveRecord::RecordNotFound)
  end
  
  it "should delete uninitialized members" do
    @importer.deleted_members.size.should == 2
    lambda { Organization.find(@uiorg1.id) }.should raise_error(ActiveRecord::RecordNotFound)
  end
end
  

  
describe AssociationMemberImport, "that has uninitialized and existing members" do
  before(:each) do
    @importer = AssociationMemberImport.new(valid_importer_params.with('update' => true))
    @importer.file = valid_csv_file
    @association = Factory(:association)
    @importer.association = @association
    
    @org1 = Factory(:organization, 
                    :email => "joe.wilson@importedfirm.com", 
                    :name => "Imported Firm", 
                    :contact_name => "This shouldn't change")
                    
    @uiorg1 = Factory(:uninitialized_association_member, 
                      :email => "josh@fleck.com", 
                      :name => "This should change", 
                      :contact_name => "Josh Fleck")
    
    @uiorg2 = Factory(:uninitialized_association_member, 
                      :email => "this@should.change", 
                      :name => "Imported Firm 3", 
                      :contact_name => "David Peterson")
                      
    @uiorg3 = Factory(:uninitialized_association_member, 
                      :email => "brian.terlson@gmail.com", 
                      :name => "Imported Firm 4", 
                      :contact_name => "This Should Change")
                                            
    [@org1, @uiorg1, @uiorg2, @uiorg3].each do |o|
      @importer.association.organizations << o
    end
                      
    @importer.import!
  end
    it "should not update exiting non-uninitialized members" do
      org = Organization.find(@org1.id)
      org.contact_name.should == "This shouldn't change"
    end
        
    it "should update uninitialized members name" do
      org = Organization.find(@uiorg1.id)
      org.name.should == "Imported Firm 2"
    end
    
    it "should update uninitialized members email" do
      org = Organization.find(@uiorg2.id)
      org.email.should == "david@peterson.com"
    end
    it "should update uninitialized members contact name" do
      org = Organization.find(@uiorg3.id)
      org.contact_name.should == "Brian Terlson"
    end
end

describe AssociationMemberImport, "that has a missing CSV file" do
  before(:each) do
    @importer = AssociationMemberImport.new(valid_importer_params.with('destroy' => true))

    @association = Factory(:association)
    @importer.association = @association
  end
    it "should raise an error" do
      lambda { @importer.import! }.should raise_error(AssociationMemberImport::NoImportFile)
    end
end

describe AssociationMemberImport, "that has special case input" do
  before(:each) do
    @importer = AssociationMemberImport.new(valid_importer_params.with('destroy' => true))
    
    @association = Factory(:association)
    @importer.association = @association
  end
  
  describe AssociationMemberImport, "that has an ampersand" do
    before(:each) do
      @importer.file = "Imported & Firm, Joe Wilson, joe.wilson@importedfirm.com, 55407, 20, 30"
      @importer.import!
    end
    
    it "should consider the input valid" do
       @importer.valid_members.size.should == 1
    end
  end
  
  describe AssociationMemberImport, "that has a 10 digit zipcode" do
    before(:each) do
      @importer.file = "Imported Firm, Joe Wilson, joe.wilson@importedfirm.com, 55407-1234, 20, 30"
      @importer.import!
    end
    
    it "should consider the input valid" do
       @importer.valid_members.size.should == 1
    end
  end
  
  describe AssociationMemberImport, "that is missing required of inputs" do
    before(:each) do
      @importer.file = "Imported Firm,,, 55407, 20, 30"
      @importer.import!
    end
    
    it "should not consider the input valid" do
       @importer.invalid_members.size.should == 1
    end
  end
  
  describe AssociationMemberImport, "has a malformated row" do
    before(:each) do
      @importer.file = "Imported Firm 1, Joe Wilson, joe.wilson1@importedfirm.com
                        Imported Firm 2, Joe Wilson, joe.wilson2@importedfirm.com, 55407, 20, 30, 12312, 12312, 123,12 312
                        Imported Firm 3, Joe Wilson, joe.wilson3@importedfirm.com, , , 55407, 20, 3
                         , , , , , "
      @importer.import!
    end
    
    it "should consider the input valid if there are no validation errors" do
      @importer.valid_members.size.should == 3
    end
    
    it "shouldn't consider the input valid or invalid if there's no useful info" do
      @importer.invalid_members.size.should == 0
    end
  end
end

describe AssociationMemberImport, "that has data in the incorrect order" do
  before(:each) do
    @importer = AssociationMemberImport.new(valid_importer_params.with('destroy' => true))

    @association = Factory(:association)
    @importer.association = @association
    
    @importer.file = "Michele Ricci,Micheler@determan.com,Determan Brownie Inc
    Mike Kuhl,mgk@viking-norseman.com,Viking Drill & Tool Inc.
    Lee Koktan,lkoktan@burnsengineering.com,Burns Engineering Inc.
    Gary Heyn,gary_heyn@tolomatic.com,Tolomatic Inc.
    Patrick Thielen,pthielen@theintegrisgroup.com,Integris Group The
    David Thompson,dthompson@qualitytool.com,Quality Tool Inc.
    Steve Ragaller,Sragaller@cretexinc.com,Cretex Companies Inc."
    
    @importer.import!
  end
  
  it "should have no valid members" do
    @importer.valid_members.size.should == 0
  end
  
  it "should be malformed" do
    @importer.malformws?.should == true
  end
end
