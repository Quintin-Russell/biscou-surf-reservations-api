class User < ApplicationRecord
  include UserPermissionsConstants
  include UserRolesConstants
  ### Associations
  has_many :sessions

  ### Attributes
  has_secure_password
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :phone_number, :string
  attribute :nationality, :string
  attribute :email, :string
  attribute :role, :string, default: "guest"
  attribute :permission, :string, default: "guest"

  ### Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :permission, inclusion: { in: ALL_PERMISSIONS }
  validates :role, inclusion: { in: ALL_ROLES }

  ### Normalizations
  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :first_name, :last_name, :nationality, :phone_number, with: ->(value) { value.strip }

  def self.by_email(email)
    find_by(email: email)
  end

  def management?
    MANAGEMENT_PERMISSIONS.include?(permission)
  end
end
