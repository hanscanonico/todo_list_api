# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ActionController::MimeResponds
  protect_from_forgery with: :null_session
end
