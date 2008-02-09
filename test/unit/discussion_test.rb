require File.dirname(__FILE__) + '/../test_helper'

class DiscussionTest < ActiveSupport::TestCase
  fixtures :discussions, :organizations, :surveys
  
  def setup
    @organization_one = organizations(:one)
    @organization_two = organizations(:two)
    @survey_one = surveys(:one)
    @survey_two = surveys(:two)
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_create_success
    discussion = Discussion.create(:title => 'test discussion', :organization_id => organizations(:one), :survey_id => surveys(:one))
    assert_valid discussion
  end
  
  def test_add_many_discussions
    discussion_one = Discussion.create(:title => 'test discussion 1', :organization_id => organizations(:one), :survey_id => surveys(:one))
    discussion_one_one = Discussion.create(:title => 'test discussion 1-1', :organization_id => organizations(:one), :survey_id => surveys(:one))
    discussion_one_two = Discussion.create(:title => 'test discussion 1-2', :organization_id => organizations(:one), :survey_id => surveys(:one))
    discussion_one.save
    discussion_one_one.save
    discussion_one_two.save  
    assert discussion_one.root?, "Root discussion"
    assert discussion_one.children_count == 0, "No children"
    discussion_one_one.move_to_child_of discussion_one
    discussion_one_two.move_to_child_of discussion_one
    assert discussion_one.children_count == 2, "Two discussions"
    assert discussion_one_one.child?, "First child"
    assert discussion_one_two.child?, "Second child"
    discussion_two = Discussion.create(:title => 'test discussion 2', :organization_id => organizations(:one), :survey_id => surveys(:two))
    discussion_two.save
    assert Discussion.roots.size == 2, "Allows for multiple roots"
    assert surveys(:one).discussions.root == discussion_one, "Can find root discussion from survey"
  end
end
