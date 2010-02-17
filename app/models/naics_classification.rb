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
    # Parse out some 2-4 digit number in the SIC string.
    sic_code_match = sic_code.to_s.match(/\d{2,4}/)
    return if sic_code_match.nil?

    sic_code = sic_code_match[0]

    if sic_code.length == 3 then
      sic_code.chop! # We don't support 3 digit sic codes, so turn it into a 2 digit.
    elsif sic_code.length == 4 && sic_code[2,2] == "00" then
      sic_code = sic_code[0, 2] # Sic codes ending in 00 are really 2 digit SIC codes.
    end

    find_by_sic_code(sic_code)
  end
  
  # Truncates the code to the specified length
  #
  def truncate(length = 3)
    s_code = code.to_s
    if s_code.length <= length then
      s_code
    else
      s_code[0,length]
    end
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
  
  # Required for thinking sphinx
  #
  def to_f
    code.to_f
  end
  
end
