class User < ApplicationRecord
  include UserPermissionsConstants
  include UserRolesConstants
  ### Attributes
  has_secure_password
  attribute :first_name, type: String
  attribute :last_name, type: String
  attribute :phone_number, type: String
  attribute :nationality, type: String
  attribute :email, type: String
  attribute :password_digest, type: String
  attribute :password, type: String
  attribute :role, type: String, default: 'guest'
  attribute :permission, type: String, default: 'guest'

  ### Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :permission, inclusion: { in: ALL_PERMISSIONS }
  validates :role, inclusion: { in: ALL_ROLES }


  def self.by_email(email)
    find_by(email: email)
  end
end
