class NaicsClassification < ActiveRecord::Base
  set_primary_key :code 
  acts_as_nested_set

  # In some cases we don't want to throw a record not found error if the naics code isn't found, so we can use this
  # in place of NC.find()
  def self.from_2007_naics_code(naics_2007)
    find_by_code(naics_2007)
  end

  def self.from_2002_naics_code(naics_2002)
    find_by_code_2002(naics_2002)
  end

  def self.from_sic_code(sic_code)
    sic_code = sic_code.to_s

    if sic_code.length == 3 then
      sic_code.chop! # We don't support 3 digit sic codes, so turn it into a 2 digit.
    elsif sic_code.length == 4 && sic_code[2,4] == "00" then
      sic_code = sic_code[0, 2] # Sic codes ending in 00 are really 2 digit SIC codes.
    end

    find_by_sic_code(sic_code)
  end
  
  # Some top-level nodes encompass multiple codes. This allows us to expose the hidden nodes to the users.
  #
  DISPLAY_MAP = { 31 => "31-33", 44 => "44-45", 48 => "48-49" }  
  def display_code
    if DISPLAY_MAP.has_key?(self.code) then
      DISPLAY_MAP[self.code]
    else
      self.code
    end      
  end
  
end
