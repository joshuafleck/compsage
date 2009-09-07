module OrganizationHelper
  def create_organization(*names)
    names = names.first if names.first.is_a?(Array)

    names.each do |name|
      Factory(:organization, :name => name)
    end
  end
end
