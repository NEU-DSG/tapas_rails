module ValidAuthToken
  extend ActiveSupport::Concern

  included do
    before(:each) { ensure_valid_login }
  end

  def set_auth_token(token)
    t = ActionController::HttpAuthentication::Token.
      encode_credentials(token.to_s)
    request.env['HTTP_AUTHORIZATION'] = t
  end

  def ensure_valid_login
    # Instantiate a valid API user
    user = FactoryBot.create(:user)
    set_auth_token 'test_api_key'
  end
end
