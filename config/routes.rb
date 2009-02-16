ActionController::Routing::Routes.draw do |map|
  map.root :controller => 'home'
  map.home ':page', :controller => 'home', :action => 'show', :page => /about|contact|privacy|how/

  map.resources :organizations, :collection => {:search => :any}
  
  map.resource :session

  map.resources :surveys, :collection => {:search => :any, :reports => :get }, :member => {:respond => :any, :rerun => :any, :finish_partial => :any} do |survey|
    survey.resources :questions, :collection => {:preview => :any}
    survey.resources :discussions, :member => {:report => :any}
    survey.resources :invitations, :controller => :survey_invitations, :member => {:decline => :put}
    survey.resource :report, :member => {:chart => :get}
  end
  
  map.resources :networks, :member => {:join => :any, :leave => :put, :evict => :put} do |network|
    network.resources :organizations
    network.resources :invitations, :controller => :network_invitations, :member => {:decline => :put}
  end
  
  map.resources :external_invitations
  map.resources :invitations
  map.resource :account, :member => {:forgot => :any, :reset => :any}
  
  map.signup 'signup', :controller => 'pending_accounts', :action => 'new', :conditions => { :method => :get }
  map.signup 'signup', :controller => 'pending_accounts', :action => 'create', :conditions => { :method => :post }
  
  map.login 'login', :controller => 'sessions', :action => 'new'
  map.survey_login 'survey_login', :controller => 'sessions', :action => 'create_survey_session'
  
  map.path '', :controller => 'surveys', :action => 'index'
end
