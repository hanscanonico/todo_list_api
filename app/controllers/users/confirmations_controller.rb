# app/controllers/users/sessions_controller.rb
module Users
  class ConfirmationsController < Devise::ConfirmationsController
    skip_before_action :verify_authenticity_token

    respond_to :json
  end
end
