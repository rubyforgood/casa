# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :all_casa_admins, path: "all_casa_admins", controllers: {sessions: "all_casa_admins/sessions"}
  devise_for :users, controllers: {sessions: "users/sessions"}

  authenticated :all_casa_admin do
    root to: "all_casa_admins/dashboard#show", as: :authenticated_all_casa_admin_root
  end

  authenticated :user do
    root to: "dashboard#show", as: :authenticated_user_root
  end

  devise_scope :user do
    root to: "devise/sessions#new"
  end

  devise_scope :all_casa_admins do
    root to: "all_casa_admins/sessions#new", as: :unauthenticated_all_casa_root
  end

  resources :casa_cases
  resources :case_contacts, except: %i[show]
  resources :reports, only: %i[index]
  resources :imports, only: %i[index create]
  resources :case_contact_reports, only: %i[index]

  resources :supervisors, only: %i[edit update new create]
  resources :supervisor_volunteers, only: %i[create] do
    member do
      patch :unassign
    end
  end
  resources :volunteers, only: %i[new edit create update] do
    member do
      patch :activate
      patch :deactivate
    end
  end
  resources :case_assignments, only: %i[create destroy] do
    member do
      get :unassign
      patch :unassign
    end
  end

  namespace :all_casa_admins do
    resources :casa_orgs, only: [:new, :create, :show]
  end

  # TODO: Remove, if possible. Prefer to use specific role routes.
  resources :users, only: [] do
    collection do
      get :edit
      patch :update
      patch "update_password"
    end
  end
end
