class Api::V1::UsersController < ApplicationController
  def me
    render json: { user: @current_user.as_payload }, status: :ok
  end

  def update_profile
    if @current_user.update(user_params)
      render json: { 
        message: "Profile updated successfully", 
        user: @current_user.as_payload
      }, status: :ok
    else
      render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :avatar)
  end
end
