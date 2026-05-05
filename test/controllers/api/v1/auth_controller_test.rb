require "test_helper"

class Api::V1::AuthControllerTest < ActionDispatch::IntegrationTest
  test "should get login" do
    get api_v1_auth_login_url
    assert_response :success
  end

  test "should get refresh" do
    get api_v1_auth_refresh_url
    assert_response :success
  end

  test "should get logout" do
    get api_v1_auth_logout_url
    assert_response :success
  end
end
