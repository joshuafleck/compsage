module OrganizationHelper
  def create_organization(*names)
    created_orgs = []
    names = names.first if names.first.is_a?(Array)

    names.each do |name|
      created_orgs << Factory(:organization, :name => name)
    end

    return created_orgs.size > 1 ? created_orgs : created_orgs.first
  end
end
