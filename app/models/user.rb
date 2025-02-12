class User < ApplicationRecord
  has_secure_password

  generates_token_for :password_reset, expires_in: 20.minutes do
    password_salt.last(10)
  end

  has_many :events, dependent: :destroy

  normalizes :first_name, :last_name, with: -> { _1&.strip || "" }
  normalizes :email, with: -> { _1&.strip&.downcase || "" }

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :password, allow_blank: false, length: {minimum: 10}, not_pwned: true, on: [:create, :update_password, :password_reset]
  validates :password_challenge,display: "Password",  presence: true, on: [:update_password, :change_email, :disable_2fa]

  def salutation
    if first_name.present?
      "Hi #{first_name},"
    else
      "Hi,"
    end
  end

  def name
    if first_name.present? || last_name.present?
      [first_name, last_name].compact.join(" ")
    end
  end
end
