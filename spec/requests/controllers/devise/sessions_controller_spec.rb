# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe Devise::SessionsController do
  include Committee::Rails::Test::Methods

  let!(:user) { create(:user, confirmation_sent_at: Time.zone.today, confirmation_token: 'abcde').tap(&:confirm) }

  let!(:headers) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json' } }

  describe 'POST /users/sign_in' do
    it 'issues a JWT token for valid credentials' do
      expect do
        post user_session_path, params: { user: { email: user.email, password: user.password } }.to_json,
                                headers:
      end.to change(AllowlistedJwt, :count).by(1)

      assert_request_schema_confirm
      assert_response_schema_confirm(201)

      expect(response.headers['Authorization']).to be_present
      token = response.headers['Authorization'].split.last
      expect { JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key) }.not_to raise_error
    end

    it 'does not issue token for invalid credentials' do
      post user_session_path, params: { user: { email: user.email, password: 'wrong' } }
      expect(response.headers['Authorization']).to be_nil
    end
  end

  describe 'DELETE /users/sign_out' do
    it 'signs out the user' do
      post(user_session_path,
           params: { user: { email: user.email,
                             password: user.password } }.to_json,
           headers:)

      token = response.headers['Authorization'].split.last
      decoded_token = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key).first['jti']

      expect(AllowlistedJwt.exists?(jti: decoded_token)).to be true

      auth_headers = { 'Authorization' => "Bearer #{token}" }

      delete(destroy_user_session_path, headers: auth_headers)
      assert_request_schema_confirm
      assert_response_schema_confirm(204)

      expect(AllowlistedJwt.exists?(jti: decoded_token))
        .to be false
    end
  end
end
