class ApplicationController < ActionController::API
    include ActionController::Cookies # Required to read/write HttpOnly cookies

    before_action :authenticate_request!

    private

    def authenticate_request!
        header = request.headers['Authorization']
        token = header.split(' ').last if header

        begin
        # Mathematically decode the JWT (does not hit the database)
        decoded_payload = JwtService.decode(token)
        
        # Assign the current user for the duration of the request
        @current_user = User.find(decoded_payload[:user_id])
        
        rescue JWT::ExpiredSignature
        # The frontend expects this exact 401 status to trigger its silent refresh
        render json: { error: 'Access token expired' }, status: :unauthorized
        rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        render json: { error: 'Unauthorized' }, status: :unauthorized
        end
    end

    def current_user
        @current_user
    end
end
