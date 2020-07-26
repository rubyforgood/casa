Rails.application.routes.draw do
  devise_for :all_casa_admins
  devise_for :users

  root to: "dashboard#show"

  resources :casa_cases
  resources :case_contacts
  resources :reports, only: %i[index]
  resources :case_contact_reports, only: %i[index]

  resources :supervisors, only: %i[edit update]
  resources :supervisor_volunteers, only: %i[create destroy]
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

  # TODO: Remove, if possible. Prefer to use specific role routes.
  resources :users, only: [] do
    collection do
      get :edit
      patch :update
      patch 'update_password'
    end
  end
end
