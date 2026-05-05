class UserMailer < ApplicationMailer
    def password_reset(user, token)
        @user = user
        @token = token
        # This URL points to your FRONTEND reset page
        @url = "http://localhost:5173/auth/reset-password/#{@token}"
        
        mail(to: @user.email, subject: "Reset your password")
    end

    def confirmation_email(user)
        @user = user
        @url = "http://localhost:5173/auth/confirm-email/#{@user.confirmation_token}"
        
        mail(to: @user.email, subject: "Confirm your email")
    end

    def password_updated_email(user)
        @user = user
        mail(to: @user.email, subject: 'Security Alert: Your password was updated')
    end

    def google_auth_notification(user)
        @user = user
        mail(to: @user.email, subject: "Password reset request for your account")
    end
end
