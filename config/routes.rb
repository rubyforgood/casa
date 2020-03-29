Rails.application.routes.draw do
  root to: "home#index" # needed for devise - not sure what this will actually end up being
  resources :casa_cases
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
