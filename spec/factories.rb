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

Factory.sequence :question do |n|
  "Question #{n}"
end

Factory.sequence :network do |n|
  "Network #{n}"
end

Factory.sequence :organization_name do |n|
  "Organization #{n}"
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

#definition and set up for survey
Factory.define :survey do |s|
  s.job_title 'Trailer Park Supervisor'
  s.description 'Assist in matter pertinent to the saftey of the citizens of a trailer park.'
  s.created_at (Time.now - 2.days).to_s(:db)
  s.end_date (Time.now + 5.days).to_s(:db)
  s.sponsor {|a| a.association(:organization)}
end

#definition and setup for discussion
Factory.define :discussion do |d|

end

#definition and setup for invitation
Factory.define :invitation do |i|
  
end

#definition and setup for external survey invitation
Factory.define :external_survey_invitation do |i|
  i.survey {|a| a.association(:survey)}
  i.inviter {|a| a.association(:organization)}
  i.organization_name { Factory.next(:organization_name) }
  i.email { Factory.next(:email) }
end

#definition and setup for network
Factory.define :network do |n|
  n.name { Factory.next(:network) }
  n.description {|a| "#{a.name} description"}
  n.owner {|a| a.association(:organization)}
end

#definition and setup for participation
Factory.define :participation do |p|
  p.survey {|a| a.association(:survey)}
  p.participant {|a| a.association(:organization)}
end

#definition and setup for question
Factory.define :question do |p|
  p.position { |a| a.object_id }
  p.text { Factory.next(:question) }
  p.question_type "numerical_field"
end

#definition and setup for predefined question
Factory.define :predefined_question do |p|
  p.position { |a| a.object_id }
  p.description {|a| "#{a.name} Description" }
  p.name { Factory.next(:question) }
  p.question_hash {|a| [{:question_type => "numerical_field", :text =>  "#{a.name} text" }] }
end

#definition and setup for response
Factory.define :response do |p|
  
end

