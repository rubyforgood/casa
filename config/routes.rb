Rails.application.routes.draw do
  devise_for :all_casa_admins
  devise_for :users

  root to: 'dashboard#show'


  resources :casa_cases
  resources :case_contacts
  resources :casa_orgs
  resources :reports, only: %i[show index]

  resources :volunteers, only: %i[new edit create] do
    resources :case_assignments, only: %i[create destroy index]
  end

  resources :users, only: [] do
    collection do
      get :edit
      patch :update
    end
  end
end
