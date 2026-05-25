class User < ApplicationRecord
    has_secure_password
    has_one_attached :avatar
    before_create :generate_confirmation_token
    has_many :refresh_tokens, dependent: :destroy
    has_many :task_assignments
    has_many :tasks, through: :task_assignments

    validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :password, presence: true, on: :create, if: -> { google_id.blank? }
    validates :password, length: { minimum: 6 }, if: -> { password.present? } 

    def generate_password_reset_token!
        # Generate a unique secure token
        raw_token = SecureRandom.urlsafe_base64
        # Store the hash of the token (security best practice)
        update!(
        reset_password_token: Digest::SHA256.hexdigest(raw_token),
        reset_password_sent_at: Time.current
        )
        raw_token # Return the raw token to be emailed
    end

    def password_reset_expired?
        # Token valid for 2 hours
        reset_password_sent_at < 2.hours.ago
    end

    def clear_password_reset_token!
        update!(reset_password_token: nil, reset_password_sent_at: nil)
    end

    def profile_picture_url
        return nil unless id

        if avatar.attached?
            # Return the URL for the uploaded custom image
            Rails.application.routes.url_helpers.rails_blob_url(avatar, host: 'localhost:3000') if Rails.env.development?
        elsif google_picture_url.present?
            # Fallback to the Google account picture
            google_picture_url
        else
            # Final fallback: a default placeholder or Gravatar
            "https://ui-avatars.com/api/?name=#{first_name}+#{last_name}&background=random"
        end
    end

    def as_payload
        {
            id: id,
            email: email,
            first_name: first_name,
            last_name: last_name,
            avatar_url: profile_picture_url,
            auth_method: google_id.present? ? "google" : "email"
        }
    end

    private

    def generate_confirmation_token
        self.confirmation_token = SecureRandom.urlsafe_base64.to_s
    end
end
