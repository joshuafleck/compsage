module AssociationSystem

  def self.included(base)
    base.send :helper_method, :current_association
  end

  def current_association
    return nil unless current_subdomain
    
    @association ||= Association.find_by_subdomain(current_subdomain)
  end
end
