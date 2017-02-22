class User < ActiveRecord::Base
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email, :password, :password_confirmation
  end

  attr_accessible :email, :password, :password_confirmation if Rails::VERSION::MAJOR < 4
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  delegate :can?, :cannot?, :to => :ability


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

  def ability
    @ability ||= Ability.new(self)
  end

  def user_key
    self.id.to_s
  end

  def self.find_by_user_key(key)
    self.send("find_by_nuid".to_sym, key)
  end

  # TODO - add interaction with wild apricot
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
