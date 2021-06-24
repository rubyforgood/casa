# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :all_casa_admins, path: "all_casa_admins", controllers: {sessions: "all_casa_admins/sessions"}
  devise_for :users, controllers: {sessions: "users/sessions"}

  concern :with_datatable do
    post "datatable", on: :collection
  end

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

  get "/.well-known/assetlinks.json", to: "android_app_associations#index"
  resources :casa_cases do
    resource :emancipation do
      member do
        post "save"
      end
    end

    resources :past_court_dates, only: %i[show index]

    member do
      patch :deactivate
      patch :reactivate
    end
  end

  resources :casa_admins, except: %i[destroy] do
    member do
      patch :deactivate
      patch :activate
    end
  end

  resources :case_contacts, except: %i[show] do
    member do
      post :restore
    end
    resources :followups, only: %i[create], controller: "case_contacts/followups", shallow: true do
      patch :resolve, on: :member
    end
  end
  resources :reports, only: %i[index]
  resources :case_court_reports, only: %i[index show] do
    collection do
      post :generate
    end
  end
  resources :imports, only: %i[index create] do
    collection do
      get :download_failed
    end
  end
  resources :case_contact_reports, only: %i[index]
  resources :casa_orgs, only: %i[edit update]
  resources :contact_type_groups, only: %i[new create edit update]
  resources :contact_types, only: %i[new create edit update]
  resources :hearing_types, only: %i[new create edit update]
  resources :emancipation_checklists, only: %i[index]
  resources :judges, only: %i[new create edit update]
  resources :notifications, only: :index

  resources :supervisors, except: %i[destroy] do
    member do
      patch :activate
      patch :deactivate
    end
  end
  resources :supervisor_volunteers, only: %i[create] do
    member do
      patch :unassign
    end
  end
  resources :volunteers, except: %i[destroy], concerns: %i[with_datatable] do
    member do
      patch :activate
      patch :deactivate
      patch :resend_invitation
      patch :reminder
    end
  end
  resources :case_assignments, only: %i[create destroy] do
    member do
      get :unassign
      patch :unassign
    end
  end
  resources :case_court_mandates, only: %i[destroy]

  namespace :all_casa_admins do
    resources :casa_orgs, only: [:new, :create, :show] do
      resources :casa_admins, only: [:new, :create, :edit, :update] do
        member do
          patch :deactivate
          patch :activate
        end
      end
    end
  end

  resources :all_casa_admins, only: [:new, :create] do
    collection do
      get :edit
      patch :update
      patch "update_password"
    end
  end

  resources :users, only: [] do
    collection do
      get :edit
      patch :update
      patch "update_password"
    end
  end
end
