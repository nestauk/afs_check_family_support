module ApplicationHelper
  include Pagy::UrlHelpers

  def errors
    Current.errors
  end
end
