namespace :admin do
  get "/", to: "dashboard#show", as: :dashboard

  get "/users/invite", to: "users#invite", as: :invite_user
  post "/users/invite", to: "users#send_invitation"
  resources :users, only: [:index, :show] do
    post :password_reset, to: "users#password_reset"
    post :disable_2fa, to: "users#deactivate_2fa"
    post :enable_admin, to: "users#enable_admin"
    post :disable_admin, to: "users#disable_admin"

    get :change_email, to: "users#change_email"
    post :change_email, to: "users#send_email_verification"
  end
end
