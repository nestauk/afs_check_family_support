module ApplicationHelper
  include Pagy::UrlHelpers

  def application_name
    Rails.configuration.application_name
  end

  def errors
    Current.errors
  end
end
