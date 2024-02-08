# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Devise::ConfirmationsController do
  include Committee::Rails::Test::Methods

  describe 'GET /resource/confirmation' do
    let!(:user) do
      create(:user, confirmation_sent_at: Time.zone.today, confirmation_token: 'abcde')
    end

    it 'confirms a user' do
      token = user.confirmation_token

      expect(user.confirmed_at?).to be(false)
      expect(user.confirmation_token_valid?).to be(true)

      get user_confirmation_path(confirmation_token: token)

      assert_request_schema_confirm
      assert_response_schema_confirm(200)

      expect(user.reload.confirmed_at?).to be(true)
    end

    context 'when the token is invalid' do
      it 'returns an error' do
        get user_confirmation_path(confirmation_token: 'invalid')

        assert_request_schema_confirm
        assert_response_schema_confirm(422)

        expect(json['confirmation_token'][0]).to eq('is invalid')
      end
    end

    context 'when the token is expired' do
      let!(:user) do
        user = create(:user)
        user.update_columns(confirmation_sent_at: 10.days.ago, confirmation_token: 'abcde')
        user
      end

      it 'returns an error' do
        get user_confirmation_path(confirmation_token: user.confirmation_token)

        assert_request_schema_confirm
        assert_response_schema_confirm(422)

        expect(json['email'][0]).to eq('needs to be confirmed within 3 days, please request a new one')
      end
    end
  end
end
