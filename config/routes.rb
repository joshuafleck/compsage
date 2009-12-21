ActionController::Routing::Routes.draw do |map|
  # If a subdomain is specified (excludes www) will direct to association member login
  map.root :controller => 'association_members', :action => 'sign_in', :conditions =>{ :subdomain => /[^(www)]/ }

  map.root :controller => 'home'
  map.contact 'contact', :controller => 'home', :action => 'contact'
  map.home ':page', :controller => 'home', :action => 'show', :page => /about|contact|privacy|how|tips|terms/

  map.resources :organizations, :collection => {:search => :any, :search_for_association_list => :any},
                :member => {:invite_to_survey => :post, :invite_to_network => :post}
  
  map.resource :session

  map.resources :surveys, :collection => { :search => :any, :reports => :get},
                          :member => { :respond => :any, :rerun => :any, :finish_partial => :any} do |survey|
    survey.resources :questions, :collection => {:preview => :any}, :member => {:move => :put}
    survey.resources :discussions, :member => {:report => :any}
    survey.resources :invitations, :controller => :survey_invitations,
      :member => {:decline => :put},
      :collection => {:create_for_network => :post, :send_pending => :post, :create_for_association => :post}
    survey.resource :report, :member => {:chart => :get, :suspect => :any}
    survey.resource :billing, :controller => :billing, :member => {:invoice => :any}
  end
  
  map.resources :networks, :member => {:join => :any, :leave => :any, :evict => :put} do |network|
    network.resources :organizations
    network.resources :invitations, :controller => :network_invitations, :member => {:decline => :put}
  end
  
  map.resource :account, :member => {:forgot => :any, :reset => :any}
  
  map.signup 'signup', :controller => 'pending_accounts', :action => 'new', :conditions => { :method => :get }
  map.signup 'signup', :controller => 'pending_accounts', :action => 'received', :conditions => { :method => :get }
  map.signup 'signup', :controller => 'pending_accounts', :action => 'create', :conditions => { :method => :post }
  
  map.login 'login', :controller => 'sessions', :action => 'new'
  map.survey_login 'survey_login', :controller => 'sessions', :action => 'create_survey_session'

  map.namespace 'admin' do |admin|
    admin.map '', :controller => 'dashboards', :action => 'show'
    admin.resource :dashboard
    admin.resources :surveys
    admin.resources :pending_accounts, :member => {:approve => :any, :deny => :any}
    admin.resources :billed_surveys
    admin.resources :organizations
    admin.resources :reported_discussions, :member => {:reset => :any}
  end

  map.path '', :controller => 'surveys', :action => 'index'
 
  map.namespace 'association' do |association|
    association.resource :session
    association.resources :members, :collection => {:upload => :get }
    association.resources :pdqs
    association.resource :settings

    association.map '', :controller => 'sessions', :action => 'new'
  end

  map.resource :association_member, :member => {:sign_in => :any, :login_received => :get, :initialize_account => :get}
  
end
