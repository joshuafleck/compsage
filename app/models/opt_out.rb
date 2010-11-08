class OptOut < ActiveRecord::Base
  include Authentication
  validates_format_of :email, :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD
  validates_uniqueness_of :email, :message => "has already been opted out. Please contact us if you are still receiving communications from us."
end
