Rails.application.routes.draw do
  resources :supervisor_volunteers
  devise_for :users
  root to: "casa_cases#index" # needed for devise - not sure what this will actually end up being
  resources :casa_cases
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
