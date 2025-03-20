module HttpError
  class Forbidden < StandardError; end

  class NotFound < StandardError; end

  ActionDispatch::ExceptionWrapper
    .rescue_responses
    .merge!({
      Forbidden.to_s => :forbidden,
      NotFound.to_s => :not_found,
    })
end
