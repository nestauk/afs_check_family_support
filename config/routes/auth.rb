get "auth", to: "users/authentication#sign_in"
post "auth", to: "users/authentication#authenticate"
get "auth/2fa", to: "users/two_factor#challenge", as: "challenge_2fa"
post "auth/2fa", to: "users/two_factor#verify"
get "signout", to: "users/authentication#sign_out"
post "signout", to: "users/authentication#sign_out"

namespace :users do
  get "forgot_password", to: "password_reset#forgot_password"
  post "forgot_password", to: "password_reset#send_password_reset"
  get "password_reset/:sid", to: "password_reset#set_password", as: :password_reset
  patch "password_reset/:sid", to: "password_reset#update_password"

  get "account", to: "account#index"

  namespace :account do
    get "activate/:signed_email", to: "activation#new", as: :activate
    post "activate/:signed_email", to: "activation#create"

    get "edit_name", to: "name#edit"
    patch "edit_name", to: "name#update"

    get "edit_email", to: "email#edit"
    post "edit_email", to: "email#send_verification"
    get "confirm_email/:signed_email", to: "email#confirm", as: :confirm_email
    patch "confirm_email/:signed_email", to: "email#update"

    get "edit_password", to: "password#edit"
    patch "edit_password", to: "password#update"

    get "disable_2fa", to: "two_factor#disable"
    patch "disable_2fa", to: "two_factor#deactivate"
    get "enable_2fa", to: "two_factor#enable"
    patch "enable_2fa", to: "two_factor#activate"
  end
end
