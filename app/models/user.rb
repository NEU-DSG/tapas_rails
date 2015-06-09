class User < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation if Rails::VERSION::MAJOR < 4
  # Connects this user object to Blacklights Bookmarks. 
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def api_key=(api_key)
    @api_key = Digest::SHA512.hexdigest api_key
    self.encrypted_api_key = @api_key
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  private 

    def generate_api_key
      key = Devise.friendly_token

      @api_key = Digest::SHA512.hexdigest key

      if User.where(:encrypted_api_key => @api_key)
        generate_api_key
      else
        self.encrypted_api_key = @api_key 
      end
    end
end
