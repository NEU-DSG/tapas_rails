module ControllerHelpers
  def login_admin(admin=nil)
    @request.env['devise.mapping'] = Devise.mappings[:admin]
    admin ||= FactoryBot.create(:user, admin_at: Time.now)
    sign_in admin
  end

  def login_user(user=nil)
    @request.env['devise.mapping'] = Devise.mappings[:user]
    user ||= FactoryBot.create(:user)
    sign_in user
  end
end
