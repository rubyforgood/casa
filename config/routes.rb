Rails.application.routes.draw do
  devise_for :all_casa_admins
  devise_for :users

  root to: "dashboard#show"

  resources :casa_cases
  resources :case_contacts
  resources :reports, only: %i[index]
  resources :case_contact_reports, only: %i[index]

  resources :volunteers, only: %i[new edit create update] do
    member do
      get :deactivate
      patch :deactivate
    end
  end
  resources :case_assignments, only: %i[create destroy] do
    member do
      get :unassign
      patch :unassign
    end
  end

  resources :users, only: [] do
    collection do
      get :edit
      patch :update
    end
  end
end
