Rails.application.routes.draw do
  draw :admin
  draw :auth
  draw :development

  root "profiles#new"

  get "dashboard", to: "dashboard#show"

  resources :profiles, only: %i[new create]
  get "results/:id", to: "profiles#results", as: :results
  get "services/:id/(:check_id)", to: "services#show", as: :service
end
