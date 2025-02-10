Rails.application.routes.draw do
  draw :admin
  draw :auth

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  get "msf-test/start" => "msf_test/msf_test#start", :as => :msf_test_start
  get "msf-test" => "msf_test/msf_test#show", :as => :msf_test
  post "msf-test" => "msf_test/msf_test#action"

  # Defines the root path route ("/")
  # root "posts#index"
  root "component_library#index", as: :dashboard

  unless Rails.env.production?
    get "/component-library", to: "component_library#index"
  end

  if Rails.env.test?
    get "/testing/get_session", to: "testing/testing#get_session"
    post "/testing/set_session", to: "testing/testing#set_session"
  end
end
