require File.dirname(__FILE__) + '/../test_helper'

class NetworkTest < ActiveSupport::TestCase
  fixtures :networks, :organizations
  
  def setup
    @network_one = networks(:one)
    @organization_one = organizations(:one)
    @organization_two = organizations(:two)
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_create_success
    network = Network.create(:title => 'Ping Pong', :organization_id => organizations(:one))
    assert_valid network
  end
  
  def test_add_many_organization
    assert @network_one.organizations.count == 0, "No organizations"
    @network_one.organizations << organizations(:one)
    @network_one.organizations << organizations(:two) 
    assert @network_one.organizations.count == 2, "Two organizations"
    assert @network_one.organization == organizations(:one), "Parent organization"
    #print @organization_one.networks
    #print @organization_two.networks
  end
  
end
