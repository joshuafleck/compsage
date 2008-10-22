require 'factory_girl'
#sequences for organization.
Factory.sequence :latitude do |n|
  0.784272 + n / 10000
end

Factory.sequence :longitude do |n|
  -1.62759 - n / 10000
end

Factory.sequence :email do |n|
  "joe.somebody#{n}@fake.com"
end

#defining an organization.
Factory.define :organization do |o|
  o.name 'Iced Inc'
  o.email { Factory.next(:email) }
  o.city 'Minneapolis'
  o.state 'MN'
  o.zip_code '55413'
  o.industry 'Healthcare: Managed Care'
  o.latitude { Factory.next(:latitude) }
  o.longitude { Factory.next(:longitude) }
  o.crypted_password '27e5532e75526ff4574e3e8c8c2a48fb97415765'
  o.salt 'asdf'
  o.created_at 40.days.ago.to_s(:db)
  o.contact_name 'David Peterson'
end

Factory.define :survey do |s|
  s.job_title 'Trailer Park Supervisor'
  s.description 'Assist in matter pertinent to the saftey of the citizens of a trailer park.'
  s.created_at (Time.now - 2.days).to_s(:db)
  s.end_date (Time.now + 5.days).to_s(:db)
  s.sponsor {|a| a.association(:organization)}
end