require "test_helper"

class WebhookControllerTest < ActionDispatch::IntegrationTest
  test "should get health" do
    get webhook_health_url
    assert_response :success
  end
end
