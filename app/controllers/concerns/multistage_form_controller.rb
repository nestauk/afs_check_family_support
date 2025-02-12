class MultistageFormController < ApplicationController
  STAGE_KEY = :_stage

  before_action :load_session
  after_action :save_session, only: :action

  rescue_from ActiveModel::ValidationError, with: :validation_error

  attr_accessor :data

  def form_url
    raise StandardError.new "form_url not implemented"
  end

  def add_stage(stage)
    @stages ||= []
    @stages << stage
  end

  def current_stage
    return @current_stage unless @current_stage.nil?

    @current_stage = @data[STAGE_KEY].constantize.new(self)
    @current_stage.request = request
    @current_stage.response = response

    @current_stage
  end

  def go_to_stage(stage)
    @data[STAGE_KEY] = stage.name
    save_session

    redirect_to form_url
  end

  def load_session
    @data = if session.has_key?(session_key)
      session[session_key].deep_symbolize_keys
    else
      {
        STAGE_KEY => @stages.first.name
      }
    end
  end

  def save_session
    session[session_key] = @data
  end

  def clear_session
    session[session_key] = nil
  end

  def session_key
    "#{self.class.name}.data"
  end

  def show
    current_stage.dispatch(:show, request, response)
  end

  def validation_error
    show
  end

  def start
    clear_session

    redirect_to form_url
  end

  def action
    @data.merge! params.except(:controller, :action, :authenticity_token, :_method).to_unsafe_hash.symbolize_keys

    action = "#{request.POST["action"]}_action"

    if action == "submit_action"
      return submit
    end

    stage = current_stage

    if stage.respond_to? action
      return current_stage.public_send(action)
    end

    raise StandardError.new "Unhandled action: #{stage.class.name}.#{action}"
  end
end
