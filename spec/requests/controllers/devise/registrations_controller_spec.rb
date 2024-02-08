# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Devise::RegistrationsController do
  include Committee::Rails::Test::Methods

  describe 'POST /users' do
    let!(:headers) { { 'Content-Type' => 'application/json' } }
    let(:user_params) do
      { user: { email: 'test1@gmail.com', password: 'password123' } }
    end

    it 'creates a new user' do
      expect do
        post user_registration_path, params: user_params.to_json, headers:
      end.to change(User, :count).by(1)

      assert_request_schema_confirm
      assert_response_schema_confirm(201)

      expect(json['email']).to eq('test1@gmail.com')
    end

    context 'when the email is invalid' do
      let(:user_params) do
        { user: { email: 'invalid', password: 'password123' } }
      end

      it 'returns an error' do
        post(user_registration_path, params: user_params.to_json, headers:)

        assert_request_schema_confirm
        assert_response_schema_confirm(422)
        expect(json['errors']['email'][0]).to eq('is invalid')
      end
    end

    context 'when the password is invalid' do
      let(:user_params) do
        { user: { email: 'test1@gmail.com', password: 'short' } }
      end

      it 'returns an error' do
        post(user_registration_path, params: user_params.to_json, headers:)

        assert_request_schema_confirm
        assert_response_schema_confirm(422)

        expect(json['errors']['password'][0]).to eq('is too short (minimum is 6 characters)')
      end
    end
  end
end
