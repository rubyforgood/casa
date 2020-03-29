Rails.application.routes.draw do
  devise_for :all_casa_admins
  devise_for :users

  root to: 'casa_cases#index' # needed for devise - not sure what this will actually end up being
  resources :casa_cases
  resources :case_contacts
  resources :casa_orgs
  resources :case_assignments
  resources :supervisor_volunteers
end
