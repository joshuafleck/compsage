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
  
  it "should find by naics 2007 code" do
    code = Factory(:naics_classification, :code => '123456')
    NaicsClassification.from_2007_naics_code('123456').should == code
  end

  it "should find by naics 2002 code" do
    code = Factory(:naics_classification, :code_2002 => '123456')
    NaicsClassification.from_2002_naics_code('123456').should == code
  end

  it "should find by 2 digit SIC codes" do
    code = Factory(:naics_classification, :sic_code => '12')
    NaicsClassification.from_sic_code('12').should == code
  end

  it "should find by 3 digit SIC codes by finding the 2 digit code" do
    code = Factory(:naics_classification, :sic_code => '12')
    NaicsClassification.from_sic_code('123').should == code
  end

  it "should find by 4 digit SIC codes" do
    code = Factory(:naics_classification, :sic_code => '1234')
    NaicsClassification.from_sic_code('1234').should == code
  end

  it "should not be upset with text around a 2 digit SIC code" do
    code = Factory(:naics_classification, :sic_code => '12')
    NaicsClassification.from_sic_code('Industry12 Code').should == code
    NaicsClassification.from_sic_code('12 Code').should == code
    NaicsClassification.from_sic_code('Industry Something 12').should == code
  end

  it "should not be upset with text around a 3 digit SIC code" do
    code = Factory(:naics_classification, :sic_code => '12')
    NaicsClassification.from_sic_code('Industry 123 Code').should == code
    NaicsClassification.from_sic_code('123 Code').should == code
    NaicsClassification.from_sic_code('Industry 123').should == code
  end

  it "should not be upset with text around a 4 digit SIC code" do
    code = Factory(:naics_classification, :sic_code => '1234')
    NaicsClassification.from_sic_code('Industry 1234 Code').should == code
    NaicsClassification.from_sic_code('1234 Code').should == code
    NaicsClassification.from_sic_code('Industry 1234').should == code
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
