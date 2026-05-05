# app/controllers/api/v1/password_resets_controller.rb
class Api::V1::PasswordResetsController < ApplicationController
  skip_before_action :authenticate_request!

  def create
    user = User.find_by(email: params[:email].downcase)

    if user
      if user.google_id.present?
        # Send an alert email telling them to use Google Login
        UserMailer.google_auth_notification(user).deliver_now
      else
        # Standard flow for email/password users
        raw_token = user.generate_password_reset_token!
        UserMailer.password_reset(user, raw_token).deliver_now
      end
    end

    # Consistent message for the frontend to prevent email discovery
    render json: { message: "Instructions have been sent to your email" }, status: :ok
  end

  def update
    hashed_token = Digest::SHA256.hexdigest(params[:id])
    
    # Strictly find users who DO NOT have a google_id
    user = User.where(google_id: nil).find_by(reset_password_token: hashed_token)

    if user.present? && !user.password_reset_expired?
      if user.update(password: params[:password])
        user.clear_password_reset_token!
        user.refresh_tokens.destroy_all 
        render json: { message: "Password has been reset successfully" }, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "Token is invalid or has expired" }, status: :not_found
    end
  end
end