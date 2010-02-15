class AssociationMemberImport
  # Valid options:
  # * Update: Update existing members with new information. Default true.
  # * Create: Create new members that don't already exist. Default true.
  # * Destroy: Destroy members that aren't a part of the import. Default false.
  # * Headers: Whether the CSV file contains headers. Default false.
  # * Classification: What industry classification is used. Valid options are naics2007, naics2002, and sic.
  #
  # Flags here are strings since the keys may come from form values.
  DEFAULT_OPTIONS = {'update' => true,
                     'create' => true,
                     'destroy' => false,
                     'headers' => false,
                     'classification' => 'naics2007'}.freeze
  
  attr_accessor :association, :file, :column_map, :valid_members, :invalid_members, :deleted_members, :skipped_members,
                :options

  # Maps CSV columns to organization attributes
  DEFAULT_COLUMN_MAP = {:name => 0,
                        :contact_name => 1,
                        :email => 2,
                        :zip_code => 3,
                        :size => 4,
                        :naics_code => 5}

  class InvalidRow < RuntimeError; end
  class NoImportFile < RuntimeError; end

  # Set options an initialize our member arrays.
  #
  def initialize(options = {})
    # Need to convert "true" to true and "false" to false to facilitate passing booleans from form params.
    @options = DEFAULT_OPTIONS.merge(options.inject({}) { |acc, value|
      acc[value.first] = if value.last == "true" then
                           true
                         elsif value.last == "false" then
                           false
                         else
                           value.last
                         end
      acc
    })
    @valid_members   = []
    @invalid_members = []
    @deleted_members = []
    @skipped_members = []
  end
  
  # Import from the specified CSV file. Raises AssociationMemberImport::NoImportFile if you've forgotten to specify an
  # import file. Also raises any number of FCSV errors in the case of a malformed CSV file.
  #
  def import!
    raise NoImportFile if @file.nil?

    FCSV.parse(@file, :headers => @options['headers']) do |row|
      begin
        member = create_member_from_csv(row)

        next if member.nil?

        if member.valid?
          @valid_members << member
        else
          @invalid_members << member
        end
      rescue InvalidRow => e
        # do nothing for now, since we don't have a name or email at this point it would be hard to display a
        # meaningful error message.
      end
    end

    if @options['destroy']
      current_org_ids = (@valid_members + @invalid_members).collect{|o| o.id}.compact
      existing_org_ids = @association.organization_ids

      # removed = previous - current (eg. anything in previous not present in current)
      # We may have some valid IDs in invalid members that were simply not updated because of some invalid data, so we
      # pull in those IDs as well.
      removed_org_ids = @association.organization_ids - (@valid_members + @invalid_members).collect{|o| o.id}.compact
      removed_orgs = @association.organizations.find(removed_org_ids)

      removed_orgs.each do |org|
        @association.remove_member(org) 
        @deleted_members << org
      end
    end
  end
  
  private

  # Creates an association member from the given row in the CSV import. May return nil if the member doesn't exist in
  # the database yet and the options tell us we can't create them.
  def create_member_from_csv(row)
    attributes = attributes_from_csv(row)
    member     = find_or_initialize_member(attributes)
    
    # If the member isn't uninitialized, we can't update it. Also, don't update if the options tell us not to.
    if member.association_can_update? && @options['update']
      member.attributes = attributes
    end

    if member.new_record? && !@options['create']
      # We can't create members.
      @skipped_members << member

      return nil
    else
      member.save
      return member
    end

  end

  # Maps CSV columns to attributes using the column map.
  def attributes_from_csv(row)
    map = @column_map || DEFAULT_COLUMN_MAP

    attrs = {}

    map.each { |attr, index| attrs[attr] = (row[index] || "").strip }

    if attrs[:naics_code] then
      # Now assign industry.
      case @options['classification']
      when 'naics2007'
        # Here we attempt to match against our database of codes because we don't want bogus codes sitting around. If the
        # code isn't found, the organization's code will be null.
        attrs[:naics_code] = NaicsClassification.from_2007_naics_code(attrs[:naics_code]).try(:code).try(:to_s)
      when 'naics2002'
        attrs[:naics_code] = NaicsClassification.from_2002_naics_code(attrs[:naics_code]).try(:code).try(:to_s)
      when 'sic'
        attrs[:naics_code] = NaicsClassification.from_sic_code(attrs[:naics_code]).try(:code).try(:to_s)
      end
    end

    return attrs
  end

  # Searches the association for an existing org by either name or email. If such an association is not found, then
  # create a new member.
  #
  # Note: New member may return an existing org if an org with that contact email is already in the database.
  #
  def find_or_initialize_member(attributes)
    member = if attributes[:name].blank? && attributes[:email].blank?
               raise InvalidRow
             elsif attributes[:name].blank?   # Find by contact email
               @association.organizations.find_by_email(attributes[:email])
             elsif attributes[:email].blank?  # Find by organization name
               @association.organizations.find_by_name(attributes[:name])
             else                             # Find by either name or email
               @association.organizations.find(:first,
                                               :conditions => ['name = ? OR email = ?',
                                                               attributes[:name],
                                                               attributes[:email]])
             end
    
    return member || @association.new_member(attributes)
  end
end
