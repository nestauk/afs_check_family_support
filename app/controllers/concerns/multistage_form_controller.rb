class MultistageFormController < ApplicationController
  STAGE_KEY = :_stage

  # This controller is a middle manager so disable all existing callbacks to prevent duplication
  reset_all_callbacks

  before_action :load_session
  after_action :save_session, only: :action

  rescue_from ActiveModel::ValidationError, with: :validation_error

  attr_accessor :data
  attr_accessor :stages

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

  def load_session
    @data = if session.has_key?(session_key)
      session[session_key].deep_symbolize_keys
    else
      {
        STAGE_KEY => default_stage,
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
    track_event "Restarted #{self.class.module_parent_name}"

    redirect_to form_url
  end

  def action
    @data.merge! params.except(:controller, :action, :authenticity_token, :_method).to_unsafe_hash.symbolize_keys

    action = :"#{request.POST["action"]}_action"

    stage = current_stage

    if stage.respond_to? action
      current_stage.dispatch(action, request, response)

      return
    end

    raise StandardError.new "Unhandled action: #{stage.class.name}.#{action}"
  end

  def track_event(name, **args)
    args[:form] ||= self.class.module_parent_name

    ahoy.track name, args
  end

  def self.password(password)
    unless Rails.env.test?
      define_method(:password) { password }
    end
  end

  def default_stage
    if respond_to? :password
      MultistageFormPasswordProtected.name
    else
      @stages.first.name
    end
  end

  def self.local_prefixes
    [name.deconstantize.underscore]
  end
end
