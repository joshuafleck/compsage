ActionController::Routing::Routes.draw do |map|

  map.resources :organizations, :collection => {:search => :any}
  
  map.resource :session

  map.resources :surveys, :collection => {:search => :any, :my => :get}, :member => {:respond => :post} do |survey|
    survey.resources :questions
    survey.resources :discussions, :member => {:report => :any}
    survey.resources :invitations, :controller => :survey_invitations
    survey.resource :report
  end
  
  map.resources :networks, :member => {:join => :put, :leave => :put} do |network|
    network.resources :organizations
    network.resources :invitations, :controller => :network_invitations
  end
  
  map.resources :external_invitations
  map.resources :invitations
  map.resource :account
  map.resource :dashboard
  
  map.signup 'signup', :controller => 'pending_accounts', :action => 'new', :conditions => { :method => :get }
  map.signup 'signup', :controller => 'pending_accounts', :action => 'create', :conditions => { :method => :post }
  
  map.login 'login', :controller => 'sessions', :action => 'new'
  map.survey_login 'survey_login', :controller => 'sessions', :action => 'create_survey_session'
  
  map.path '', :controller => 'dashboards', :action => 'show'
end
