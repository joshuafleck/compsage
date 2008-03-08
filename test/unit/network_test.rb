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
    network = Network.create(:title => 'Ping Pong', :owner_id => organizations(:one))
    assert_valid network
  end
  
  def test_add_many_organization
    assert @network_one.organizations.count == 0, "No organizations"
    @network_one.organizations << organizations(:one)
    @network_one.organizations << organizations(:two) 
    @network_one.save
    assert @network_one.organizations.count == 2, "Two organizations"
    assert @network_one.owner == organizations(:one), "Parent organization"
    assert @organization_one.owned_networks[0] == @network_one, "Parent organization reverse"
    assert @organization_one.networks[0] == @network_one, "One network membership"
  end
  
end
