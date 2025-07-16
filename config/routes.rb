Rails.application.routes.draw do
  draw :admin
  draw :auth
  draw :development

  root "profiles#new"

  get "dashboard", to: "dashboard#show"

  resources :profiles, only: %i[new create]
  resources :providers, only: %i[new create show]

  get "results/:id", to: "profiles#results", as: :results
  get "services/:id/(:check_id)", to: "services#show", as: :service

  get "results/:id/favourites", to: "favourites#index", as: :favourites
  post "results/:id/favourites/:provision_id", to: "favourites#create", as: :create_favorite
  delete "results/:id/favourites/:provision_id", to: "favourites#destroy", as: :destroy_favorite
end
