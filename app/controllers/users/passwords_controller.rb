# frozen_string_literal: true

# app/controllers/users/passwords_controller.rb

module Users
  class PasswordsController < Devise::PasswordsController
    respond_to :json

    # POST /resource/password
    def create
      self.resource = resource_class.send_reset_password_instructions(resource_params)
      yield resource if block_given?

      if successfully_sent?(resource)
        render json: { message: 'Reset password instructions sent.' }, status: :ok
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PUT /resource/password
    def update
      self.resource = resource_class.reset_password_by_token(resource_params)
      yield resource if block_given?

      if resource.errors.empty?
        unlock_resource_if_unlockable
        render json: { message: 'Password reset successfully.' }, status: :ok
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end

    protected

    def unlock_resource_if_unlockable
      resource.unlock_access! if unlockable?(resource)
    end

    def resource_params
      params.require(:user).permit(:email, :password, :password_confirmation, :reset_password_token)
    end
  end
end
