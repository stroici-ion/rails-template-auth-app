class RefreshToken < ApplicationRecord
  belongs_to :user

  validates :crypted_token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  # Scope to easily find tokens that are still valid
  scope :active, -> { where(revoked_at: nil).where('expires_at > ?', Time.current) }

  # Helper method to check if a token is expired
  def expired?
    expires_at <= Time.current
  end

  # Helper method to check if a token is revoked
  def revoked?
    revoked_at.present?
  end

  # Action to revoke the token
  def revoke!
    update!(revoked_at: Time.current)
  end
end
