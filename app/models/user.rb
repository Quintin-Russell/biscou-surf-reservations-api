class User < ApplicationRecord
  ### Attributes
  has_secure_password
  attribute :first_name, type: String
  attribute :last_name, type: String
  attribute :phone_number, type: String
  attribute :nationality, type: String
  attribute :email, type: String
  attribute :password_digest, type: String
  attribute :password, type: String
  attribute :role, type: String
  attribute :permission, type: String

  ### Validations
  validates :email, presence: true, uniqueness: true

  ### Scopes
  scope :by_email, ->(email) { find_by(email: email) }
end
