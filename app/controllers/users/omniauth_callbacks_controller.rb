module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token, only: %i[google_oauth2]

    def google_oauth2
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        redirect_user_to_original_url
      else
        render json: { errors: @user.errors.full_messages.join('\n') }, status: :unprocessable_entity
      end
    end

    private

    def redirect_user_to_original_url
      sign_in(@user)
      token = @user.generate_jwt_token
      redirect_uri = session[:redirect_uri]
      redirect_url = "#{redirect_uri}?token=#{token}"
      session[:redirect_uri] = nil
      redirect_to redirect_url, allow_other_host: true
    end
  end
end
