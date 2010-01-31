require 'rubygems'
require 'fastercsv'

def print_help
  puts "USAGE: #{__FILE__} <2007 NAICS csv> <2007 to 2002 NAICS csv> <1987 2002 NAICS to SIC csv> <output file>"
  puts "Output file will contain entries with 2007 NAICS codes to 2002 CSV codes"
end

naics_2007_file         = ARGV[0]
naics_2007_to_2002_file = ARGV[1]
naics_to_sic_file       = ARGV[2]
output_file             = ARGV[3]

naics_2007_to_sic = {}
sic_to_2007_naics = {}
naics_2002_to_2007 = {}
naics_2007_to_2002 = {}

print_help if naics_2007_file.nil? || naics_2007_to_2002_file.nil? || naics_to_sic_file.nil?

#  Load in our naics 2007 to 2002 conversion
FasterCSV.foreach(naics_2007_to_2002_file) do |f|
  naics_2007 = f[0].to_i
  naics_2002 = f[2].to_i

  naics_2007_to_2002[naics_2007] ||= []

  naics_2007_to_2002[naics_2007].push(naics_2002)
end

# Some 2002 NAICS codes were split into multiple 2007 NAICS codes while some were combined into a single NAICS code.
# The following will attempt to make a best guess at a 1:1 mapping by mapping to the same code if it was preserved in
# both years. If the candidate codes are different from the original code, then we just pick the first.
naics_2007_to_2002.each do |naics_2007, candidates|
  if candidates.size > 1 && candidates.include?(naics_2007) then
    naics_2007_to_2002[naics_2007] = naics_2007
  else
    naics_2007_to_2002[naics_2007] = candidates.first
  end

  # Preserve a reverse mapping
  naics_2002_to_2007[naics_2007_to_2002[naics_2007]] = naics_2007
end

# Map each SIC code to a 2007 NAICS code
FasterCSV.foreach(naics_to_sic_file) do |f|
  naics_2002 = f[0].to_i
  sic_code   = f[2].to_i

  naics_2007 = naics_2002_to_2007[naics_2002]
  naics_2007_to_sic[naics_2007] = sic_code

  # We will also need a list of all the naics 2007 codes that map to 2 digit SIC codes in order to derive a best
  # match for the 2 digit SIC codes.
  short_sic = sic_code.to_s[0,2].to_i
  sic_to_2007_naics[short_sic] ||= []
  sic_to_2007_naics[short_sic].push naics_2007
end

# determine the best 3 digit NAICS code to map to for each 2 digit SIC code.
sic_to_2007_naics.each do |short_sic, naics_2007|
  occurrences = Hash.new(0)
  naics_2007.collect{|n| n.to_s[0,3].to_i}.each {|n| occurrences[n] += 1}
  short_naics = occurrences.sort{|a, b| b[1] <=> a[1]}.first[0]
  naics_2007_to_sic[short_naics] = short_sic
end


# Go through each naics 2007 code and find its appropriate 2002 NAICS code and SIC code.
# Since the 5 digit or fewer NAICS codes didn't change from 2002 to 2007, just copy those along.
FasterCSV.open(output_file, "w") do |csv|
  FasterCSV.foreach(naics_2007_file) do |f|
    naics_2007  = f[1].to_i
    description = f[2] 
    naics_2002  = naics_2007_to_2002[naics_2007]
    naics_2002  = naics_2007 if naics_2002.nil? && naics_2007 < 100000
    sic         = naics_2007_to_sic[naics_2007]

    csv << [naics_2007, naics_2002, sic, description]
  end
end
