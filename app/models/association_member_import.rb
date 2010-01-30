class AssociationMemberImport
  # Valid flags:
  # * Update: Update existing members with new information. Default true.
  # * Create: Create new members that don't already exist. Default true.
  # * Destroy: Destroy members that aren't a part of the import. Default false.
  # * Headers: Whether the CSV file contains headers. Default false.
  #
  # Flags here are strings since the keys may come from form values.
  DEFAULT_FLAGS = {'update' => true, 'create' => true, 'destroy' => false, 'headers' => false}.freeze
  
  attr_accessor :association, :file, :column_map, :valid_members, :invalid_members, :deleted_members, :skipped_members, :flags

  # Maps CSV columns to organization attributes
  DEFAULT_COLUMN_MAP = {:name => 0, :contact_name => 1, :email => 2, :zip_code => 3}

  class InvalidRow < RuntimeError; end
  class NoImportFile < RuntimeError; end

  # Set flags an initialize our member arrays.
  #
  def initialize(flags = {})
    # Need to convert "true" to true and "false" to false to facilitate passing booleans from form params.
    @flags = DEFAULT_FLAGS.merge(flags.inject({}) { |acc, value|
      acc[value.first] = (value.last == "true" ? true : false )
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

    FCSV.parse(@file, :headers => @flags['headers']) do |row|
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

    if @flags['destroy']
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
  # the database yet and the flags tell us we can't create them.
  def create_member_from_csv(row)
    attributes = attributes_from_csv(row)
    member     = find_or_initialize_member(attributes)
    
    # If the member isn't uninitialized, we can't update it. Also, don't update if the flags tell us not to.
    if member.association_can_update? && @flags['update']
      member.attributes = attributes
    end

    if member.new_record? && !@flags['create']
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
