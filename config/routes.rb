ActionController::Routing::Routes.draw do |map|
  map.resources :organizations

  map.resource :session

  map.resources :surveys do |survey|
    survey.resources :questions do |question|
      question.resources :responses
    end
    survey.resources :discussions
    survey.resources :invitations, :controller => :survey_invitations
    survey.resource :report
  end
  
  map.resources :networks do |network|
    network.resources :organizations
    network.resources :invitations, :controller => :network_invitations
  end
  
  map.resources :invitations
  map.resource :account
  map.resource :dashboard
  map.resources :messages
end
