# app/controllers/users/sessions_controller.rb
module Users
  class ConfirmationsController < Devise::ConfirmationsController
    respond_to :json
  end
end
