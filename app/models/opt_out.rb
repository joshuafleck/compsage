class OptOut < ActiveRecord::Base
  include Authentication
  validates_format_of :email, :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD
  validates_uniqueness_of :email, :message => "has already been opted out. Please contact us if you are still receiving communications from us."

  after_create :remove_uninitialized_orgs


  private

  # Remove any uninitialized orgs with this email address so they don't receive any further emails
  # from other people trying to survey them.
  #
  def remove_uninitialized_orgs
    Organization.find(:all, :conditions => {:uninitialized_association_member => true, :email => self.email}).each do |org|
      org.destroy
    end
  end
end
