ActionController::Routing::Routes.draw do |map|
  map.resources :surveys do |survey|
    survey.resources :questions do |question|
      question.resources :responses
    end
    survey.resources :comments
    survey.resources :invites
    survey.resource :position
  end
  
  map.resources :groups do |group|
    group.resources :users
  end
  
  map.resource :user do |user|
      user.resources :logins
  end
  map.resource :account, :controller => :user, :action => :edit
  map.resource :logins, :controller => :logins
  
  map.resources :messages
end
