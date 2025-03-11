unless Rails.env.production?
  get "/component-library", to: "component_library#show"
end

if Rails.env.test?
  get "/testing/get_session", to: "testing/testing#get_session"
  post "/testing/set_session", to: "testing/testing#set_session"
end
