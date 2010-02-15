require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NaicsClassification do
  before(:each) do
    @valid_attributes = {
      :code => 1,
      :description => 'naics description'
    }
  end

  it "should create a new instance given valid attributes" do
    NaicsClassification.create!(@valid_attributes)
  end
  
  it "should use the code as the display code when the code is not in the map" do
    naics = NaicsClassification.new(@valid_attributes)
    naics.code = 1
    naics.display_code.should == 1
  end

  it "should use the mapped code as the display code when the code is in the map" do
    naics = NaicsClassification.new(:code => 31, :description => 'test')
    naics.code = 31
    naics.display_code.should == '31-33'
  end  
end
