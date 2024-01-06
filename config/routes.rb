# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  devise_for :all_casa_admins, path: "all_casa_admins", controllers: {sessions: "all_casa_admins/sessions"}
  devise_for :users, controllers: {sessions: "users/sessions", passwords: "users/passwords"}

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
    root to: "static#index"
  end

  devise_scope :all_casa_admins do
    root to: "all_casa_admins/sessions#new", as: :unauthenticated_all_casa_root
  end

  resources :preference_sets, only: [] do
    collection do
      post "/table_state_update/:table_name", to: "preference_sets#table_state_update", as: :table_state_update
      get "/table_state/:table_name", to: "preference_sets#table_state", as: :table_state
    end
  end

  resources :health, only: %i[index] do
    collection do
      get :case_contacts_creation_times_in_last_week
      get :monthly_line_graph_data
    end
  end

  get "/.well-known/assetlinks.json", to: "android_app_associations#index"
  resources :casa_cases, except: %i[destroy] do
    resource :emancipation, only: %i[show] do
      member do
        post "save"
      end
    end

    resource :fund_request, only: %i[new create]

    resources :court_dates, only: %i[create edit new show update destroy]

    resources :placements, only: %i[create edit new show update destroy]

    member do
      patch :deactivate
      patch :reactivate
      patch :copy_court_orders
    end
  end

  resources :casa_admins, except: %i[destroy show] do
    member do
      patch :deactivate
      patch :activate
      patch :resend_invitation
      post :send_reactivation_alert
      patch :change_to_supervisor
    end
  end

  get "case_contacts/leave", to: "case_contacts#leave", as: "leave_case_contacts_form"
  resources :case_contacts, except: %i[create update] do
    member do
      post :restore
    end
    resources :form, controller: "case_contacts/form"
    resources :followups, only: %i[create], controller: "case_contacts/followups", shallow: true do
      patch :resolve, on: :member
    end
  end

  resources :reports, only: %i[index]
  get :export_emails, to: "reports#export_emails"

  resources :case_court_reports, only: %i[index show] do
    collection do
      post :generate
    end
  end
  resources :reimbursements, only: %i[index change_complete_status], concerns: %i[with_datatable] do
    patch :mark_as_complete, to: "reimbursements#change_complete_status"
    patch :mark_as_needs_review, to: "reimbursements#change_complete_status"
  end
  resources :imports, only: %i[index create] do
    collection do
      get :download_failed
    end
  end
  resources :case_contact_reports, only: %i[index]
  resources :mileage_reports, only: %i[index]
  resources :mileage_rates, only: %i[index new create edit update]
  resources :casa_org, only: %i[edit update]
  resources :contact_type_groups, only: %i[new create edit update]
  resources :contact_types, only: %i[new create edit update]
  resources :hearing_types, only: %i[new create edit update] do
    resources :checklist_items, only: %i[new create edit update destroy]
  end
  resources :emancipation_checklists, only: %i[index]
  resources :judges, only: %i[new create edit update]
  resources :notifications, only: :index
  resources :other_duties, only: %i[new create edit index update]
  resources :missing_data_reports, only: %i[index]
  resources :learning_hours_reports, only: %i[index]
  resources :learning_hour_types, only: %i[new create edit update]
  resources :learning_hour_topics, only: %i[new create edit update]
  resources :followup_reports, only: :index
  resources :placement_reports, only: :index
  resources :banners, only: %i[index new edit create update destroy]
  resources :bulk_court_dates, only: %i[new create]
  resources :case_groups, only: %i[index new edit create update destroy]
  resources :learning_hours, only: %i[index show new create edit update destroy]

  resources :supervisors, except: %i[destroy show], concerns: %i[with_datatable] do
    member do
      patch :activate
      patch :deactivate
      patch :resend_invitation
      patch :change_to_admin
    end
  end
  resources :supervisor_volunteers, only: %i[create] do
    member do
      patch :unassign
    end
  end
  resources :volunteers, except: %i[destroy], concerns: %i[with_datatable] do
    post :stop_impersonating, on: :collection
    member do
      patch :activate
      patch :deactivate
      get :resend_invitation
      get :send_reactivation_alert
      patch :reminder
      get :impersonate
    end
    resources :notes, only: %i[create edit update destroy]
  end
  resources :case_assignments, only: %i[create destroy] do
    member do
      get :unassign
      patch :unassign
      patch :show_hide_contacts
      patch :reimbursement
    end
  end
  resources :case_court_orders, only: %i[destroy]

  namespace :all_casa_admins do
    resources :casa_orgs, only: [:new, :create, :show] do
      resources :casa_admins, only: [:new, :create, :edit, :update] do
        member do
          patch :deactivate
          patch :activate
        end
      end
    end

    resources :patch_notes, only: %i[create destroy index update]

    resources :feature_flags, only: %i[index update]
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
      patch "update_email"
      patch :add_language
      delete :remove_language
    end
  end
  resources :languages, only: %i[new create edit update] do
    delete :remove_from_volunteer
  end

  direct :help do
    "https://thunder-flower-8c2.notion.site/Casa-Volunteer-Tracking-App-HelpSite-3b95705e80c742ffa729ccce7beeabfa"
  end

  get "/error", to: "error#index"

  namespace :api do
    namespace :v1 do
      namespace :users do
        post "sign_in", to: "sessions#create"
        # get 'sign_out', to: 'sessions#destroy'
      end
    end
  end
end
