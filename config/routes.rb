Rails.application.routes.draw do
  draw :admin
  draw :auth
  draw :development

  root "dashboard#show"
  get "dashboard", to: "dashboard#show"
end
