class NaicsClassification < ActiveRecord::Base
  set_primary_key :code 

  def self.from_2002_naics_code(naics_2002)
    find_by_naics_2002(naics_2002)
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
end
