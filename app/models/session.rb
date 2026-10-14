class Session < ApplicationRecord
  include AuthenticationConstants
  ### Associations
  belongs_to :user

  ### Attributes
  attribute :expires_at, :datetime, default: -> { AUTH_DURATION.from_now }

  ### Validations
  validates :expires_at, presence: true

  ### Scopes
  scope :active, -> { where("expires_at > ?", Time.current) }

  ### Methods
  def self.find_active(id)
    active.find_by(id: id)
  end

  def expired?
    expires_at <= Time.current
  end
end
