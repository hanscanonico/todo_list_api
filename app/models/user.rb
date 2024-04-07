class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Allowlist

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :jwt_authenticatable,
         :omniauthable, omniauth_providers: %i[google_oauth2],
                        jwt_revocation_strategy: self

  has_many :lists, dependent: :destroy
  has_many :tasks, through: :lists

  def confirmation_token_valid?
    return false if confirmation_sent_at.blank?

    (confirmation_sent_at + 30.days) > Time.now.utc
  end

  def mark_as_confirmed!
    self.confirmation_token = nil
    self.confirmed_at = Time.now.utc
    save!
  end

  def generate_jwt_token
    scope = :user
    token, payload = Warden::JWTAuth::UserEncoder.new.call(self, scope, nil)
    jti = payload['jti']
    exp = Time.zone.at(payload['exp'])

    AllowlistedJwt.create(
      jti:,
      exp:,
      user_id: id
    )

    token
  end

  def self.from_omniauth(auth)
    user = where(provider: auth.provider, uid: auth.uid).first

    return user if user

    update_or_create_user_from_omniauth(auth)
  end

  def self.update_or_create_user_from_omniauth(auth)
    user = find_by(email: auth.info.email)

    if user
      user.update(provider: auth.provider, uid: auth.uid)
    else
      user = create_user_from_omniauth(auth)
    end
    user
  end

  def self.create_user_from_omniauth(auth)
    user = create!(
      email: auth.info.email,
      password: Devise.friendly_token[0, 20],
      provider: auth.provider,
      uid: auth.uid
    )
    user.mark_as_confirmed!
    user
  end
end
