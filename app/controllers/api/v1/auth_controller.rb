class Api::V1::AuthController < ApplicationController
  # The user won't have a valid access token for these actions
  skip_before_action :authenticate_request!, only: [:login, :refresh, :register, :google_login, :confirm_email]

  def register
    user = User.new(user_params)
    if user.save
      UserMailer.confirmation_email(user).deliver_now
  
      render json: { message: 'User successfully created. Please check your email to confirm your account.' }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def login
    user = User.find_by(email: params[:email].to_s.downcase)
    if user && user.authenticate(params[:password])
      unless user.confirmed_email?
        return render json: { error: 'Please confirm your email address before logging in' }, status: :unauthorized
      end

      create_session_for(user, :ok, 'Login successful')
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def confirm_email
    user = User.find_by(confirmation_token: params[:token])

    if user
      # Mark as confirmed and remove the token so it can't be reused
      user.update(confirmed_email: true, confirmation_token: nil)
      render json: { message: 'Email successfully confirmed. You can now log in.' }, status: :ok
    else
      render json: { error: 'Invalid or expired confirmation token' }, status: :bad_request
    end
  end

  def refresh
    raw_token = cookies[:refresh_token]

    if raw_token.blank?
      return render json: { error: 'Refresh token missing' }, status: :unauthorized
    end

    crypted_token = Digest::SHA256.hexdigest(raw_token)
    refresh_token_record = RefreshToken.find_by(crypted_token: crypted_token)

    if refresh_token_record.nil? || refresh_token_record.revoked? || refresh_token_record.expired?
      return render json: { error: 'Invalid or expired refresh session' }, status: :unauthorized
    end

    user = refresh_token_record.user
    refresh_token_record.destroy

    new_access_token = JwtService.encode({ user_id: user.id })
    new_raw_refresh = SecureRandom.hex(32)
    
    user.refresh_tokens.create!(
      crypted_token: Digest::SHA256.hexdigest(new_raw_refresh),
      expires_at: 30.days.from_now,
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )

    set_refresh_cookie(new_raw_refresh)

    render json: { access_token: new_access_token }
  end

  def logout
    raw_token = cookies[:refresh_token]

    if raw_token.present?
      crypted_token = Digest::SHA256.hexdigest(raw_token)
      RefreshToken.find_by(crypted_token: crypted_token)&.destroy
    end

    cookies.delete(:refresh_token, 
      httponly: true, 
      secure: true,
      same_site: :none, 
    )

    render json: { message: 'Successfully logged out' }, status: :ok
  end

  def logout_all
    # 1. Destroy all refresh tokens belonging to the authenticated user
    # Because of 'dependent: :destroy' in the User model, this is clean.
    @current_user.refresh_tokens.destroy_all

    # 2. Clear the refresh token cookie from the browser
    cookies.delete(:refresh_token, 
      httponly: true, 
      secure: Rails.env.production?, 
      same_site: :lax
    )

    render json: { message: 'Successfully logged out from all devices' }, status: :ok
  end

  def google_login
    client_id = "543592430618-bsmvaihuhltlsmkq9gprds0h51ph4kmn.apps.googleusercontent.com"
    
    # 1. Verify the ID Token sent from Frontend
    validator = GoogleIDToken::Validator.new
    begin
      payload = validator.check(params[:token], client_id)
      
      email = payload['email']

      # 2. Find or Initialize the user
      user = User.find_or_initialize_by(email: email)

      # 3. Assign Google profile data
      # This handles both New and Existing users
      user.assign_attributes(
        google_id: payload['sub'],
        first_name: payload['given_name'],
        last_name: payload['family_name'],
        google_picture_url: payload['picture']
      )

      # Ensure a password exists for new records to satisfy has_secure_password
      if user.new_record?
        user.password = SecureRandom.hex(16)
      end

      # 4. Save the changes
      if user.save
        # 5. Create session (Access Token + Refresh Token Cookie)
        create_session_for(user, :ok, 'Google login successful')
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end

    rescue GoogleIDToken::ValidationError => e
      render json: { error: "Invalid Google Token: #{e.message}" }, status: :unauthorized
    end
  end

  def update_password
    # 1. Verify the current password
    unless @current_user.authenticate(params[:old_password])
      return render json: { error: 'Incorrect current password' }, status: :unauthorized
    end

    # 2. Update the password
    # Note: Because you use has_secure_password, Rails will automatically check 
    # if :password and :password_confirmation match if both are provided.
    if @current_user.update(password: params[:new_password], password_confirmation: params[:new_password_confirmation])
      
      # 3. Send the security notification email
      UserMailer.password_updated_email(@current_user).deliver_later

      # Security Best Practice: Revoke all other active sessions so if an attacker
      # had access, they are kicked out of other devices.
      # @current_user.refresh_tokens.destroy_all # (Uncomment if you want to force re-login everywhere)

      render json: { message: 'Password successfully updated.' }, status: :ok
    else
      render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def create_session_for(user, status_code, message)
    # 1. Generate Access Token
    access_token = JwtService.encode({ user_id: user.id })

    # 2. Generate Refresh Token
    raw_refresh_token = SecureRandom.hex(32)

    # 3. Save hashed Refresh Token to DB
    user.refresh_tokens.create!(
      crypted_token: Digest::SHA256.hexdigest(raw_refresh_token),
      expires_at: 30.days.from_now,
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )

    # 4. Set HttpOnly Cookie
    set_refresh_cookie(raw_refresh_token)

    # 5. Render Response
    render json: { 
      message: message,
      access_token: access_token,
      user: user.as_payload
    }, status: status_code
  end

  def set_refresh_cookie(raw_token)
    cookies[:refresh_token] = {
      value: raw_token,
      httponly: true,
      secure: true,
      same_site: :none, 
      expires: 30.days.from_now
    }
  end

  def user_params
    params.permit(:email, :password, :first_name, :last_name)
  end

  def user_data(user)
    {
      id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      # Uses the helper method in the User model we created
      avatar_url: user.profile_picture_url 
    }
  end
end