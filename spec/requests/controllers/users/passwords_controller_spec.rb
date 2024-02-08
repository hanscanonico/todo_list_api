# frozen_string_literal: true

require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe Users::PasswordsController do
  include Committee::Rails::Test::Methods

  let!(:headers) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json' } }

  describe 'POST /users/password' do
    it 'sends a password reset email' do
      user = create(:user)
      auth_headers = Devise::JWT::TestHelpers.auth_headers(headers, user)

      expect do
        post user_password_path, params: { user: { email: user.email } }.to_json,
                                 headers: auth_headers
      end.to change(ActionMailer::Base.deliveries, :count).by(1)

      assert_request_schema_confirm
      assert_response_schema_confirm(200)
    end
  end

  describe 'PUT /users/password' do
    context 'when the token is valid' do
      let!(:user) { create(:user) }

      it 'resets the password' do
        raw_token, hashed_token = Devise.token_generator.generate(User, :reset_password_token)

        user.reset_password_token = hashed_token
        user.reset_password_sent_at = Time.now.utc
        user.save

        expect do
          put user_password_path, params: { user: {
            reset_password_token: raw_token,
            password: 'newpassword',
            password_confirmation: 'newpassword'
          } }.to_json,
                                  headers:
        end.to(change { user.reload.encrypted_password })

        assert_request_schema_confirm
        assert_response_schema_confirm(200)

        expect(json['message']).to eq('Password reset successfully.')
      end
    end

    context 'when the token is invalid' do
      it 'returns an error' do
        put(user_password_path, params: { user: { reset_password_token: 'invalid',
                                                  password: 'newpassword',
                                                  password_confirmation: 'newpassword' } }.to_json,
                                headers:)

        assert_request_schema_confirm
        assert_response_schema_confirm(422)

        expect(json['errors'][0]).to eq('Reset password token is invalid')
      end
    end

    context 'when the token is expired' do
      let!(:user) do
        create(:user, reset_password_token: 'abcde', reset_password_sent_at: 1.year.ago)
      end

      it 'returns an error' do
        put(user_password_path, params: { user: { reset_password_token: user.reset_password_token,
                                                  password: 'newpassword',
                                                  password_confirmation: 'newpassword' } }.to_json,
                                headers:)

        assert_request_schema_confirm
        assert_response_schema_confirm(422)

        expect(json['errors'][0]).to eq('Reset password token is invalid')
      end
    end
  end
end
