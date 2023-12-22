# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController
    # GET /resource/confirmation/new
    # def new
    #   super
    # end

    # POST /resource/confirmation
    # def create
    #   super
    # end

    # GET /resource/confirmation?confirmation_token=abcdef
    def show
      byebug
      token = params[:confirmation_token]
      user = User.find_by(confirmation_token: token)

      if user.present? && user.confirmation_token_valid?
        user.mark_as_confirmed!
        render json: { status: 'User confirmed successfully' }
      else
        render json: { error: 'Invalid token' }, status: :unprocessable_entity
      end
    end

    # protected

    # The path used after resending confirmation instructions.
    # def after_resending_confirmation_instructions_path_for(resource_name)
    #   super(resource_name)
    # end

    # The path used after confirmation.
    # def after_confirmation_path_for(resource_name, resource)
    #   super(resource_name, resource)
    # end
  end
end
