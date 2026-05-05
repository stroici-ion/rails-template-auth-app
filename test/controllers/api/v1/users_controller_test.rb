require "test_helper"

class Api::V1::UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get me" do
    get api_v1_users_me_url
    assert_response :success
  end

  test "should get update_profile" do
    get api_v1_users_update_profile_url
    assert_response :success
  end
end
