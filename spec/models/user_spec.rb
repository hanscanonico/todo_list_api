require 'rails_helper'

RSpec.describe User do
  describe 'confirmation_token_valid?' do
    let(:user) { create(:user, confirmation_sent_at: Time.zone.today) }

    it 'returns true if the confirmation token is valid' do
      expect(user.confirmation_token_valid?).to be(true)
    end

    it 'returns false if the confirmation token is invalid' do
      user.confirmation_sent_at = 31.days.ago

      expect(user.confirmation_token_valid?).to be(false)
    end
  end

  describe 'mark_as_confirmed!' do
    let(:user) { create(:user, confirmation_token: 'token', confirmed_at: nil) }

    it 'marks the user as confirmed' do
      user.mark_as_confirmed!

      expect(user.confirmed_at).not_to be_nil
      expect(user.confirmation_token).to be_nil
    end
  end

  describe 'generate_jwt_token' do
    let(:user) { create(:user) }

    it 'creates a JWT token' do
      token = user.generate_jwt_token

      expect(token).not_to be_nil
    end
  end
end
