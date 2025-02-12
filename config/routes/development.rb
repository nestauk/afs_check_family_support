unless Rails.env.production?
  get "/component-library", to: "component_library#show"
end

if Rails.env.test?
  get "msf-test/start" => "msf_test/msf_test#start", :as => :msf_test_start
  get "msf-test" => "msf_test/msf_test#show", :as => :msf_test
  post "msf-test" => "msf_test/msf_test#action"

  get "/testing/get_session", to: "testing/testing#get_session"
  post "/testing/set_session", to: "testing/testing#set_session"
end
