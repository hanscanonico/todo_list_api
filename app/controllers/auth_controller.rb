class AuthController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[redirect_to_google]

  def redirect_to_google
    session[:redirect_uri] = params[:redirect_uri]
  end
end
