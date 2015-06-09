module ValidAuthToken
  extend ActiveSupport::Concern

  included do 
    before(:each) { ensure_valid_login }
  end

  def ensure_valid_login
    # Instantiate a valid API user
    user = FactoryGirl.create(:user)

    # Set the mock request object to have a valid Authorization header
    t = ActionController::HttpAuthentication::Token.
      encode_credentials('test_api_key')
    request.env['HTTP_AUTHORIZATION'] = t
  end
end
