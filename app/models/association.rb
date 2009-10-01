class Association < ActiveRecord::Base
  has_and_belongs_to_many :organizations

  validates_presence_of   :name, :subdomain
  validates_uniqueness_of :name, :subdomain
  validates_length_of     :subdomain, :in => 3..20
  validates_format_of     :subdomain, :with => /^[A-Za-z0-9]*$/
end
