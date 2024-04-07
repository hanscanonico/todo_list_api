# app/controllers/users/sessions_controller.rb
module Users
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json
  end
end
