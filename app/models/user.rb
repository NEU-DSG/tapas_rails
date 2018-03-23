class User < ActiveRecord::Base
  require "net/http"
  require "uri"
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  mount_uploader :avatar, AvatarUploader
  validates_integrity_of :avatar

  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email, :password, :password_confirmation, :name, :role, :bio, :account_type
  end

  attr_accessible :email, :password, :password_confirmation, :name, :role, :bio, :account_type if Rails::VERSION::MAJOR < 4
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  delegate :can?, :cannot?, :to => :ability

  belongs_to :institution

  ROLES = %w[admin paid_user unpaid_user]

  ACCOUNT_TYPES = %w[free teic]

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

  def admin?
    return self.role.eql?('admin')
  end

  def paid_user?
    return self.role.eql?('paid_user')
  end

  def unpaid_user?
    return self.role.eql?('unpaid_user')
  end

  def self.find_by_user_key(key)
    self.send("find_by_nuid".to_sym, key)
  end

  def forem_name
    self.name
  end

  def forem_email
    self.email
  end

  def check_paid_status
    api_key = ENV['WILD_APRICOT_API_KEY']
    aid = 66796
    Pluot.api_key = api_key
    Pluot.account_id = aid
    response = Pluot.contacts.filter("e-Mail eq #{self.email}")
    logger.warn(response)
    if response.blank?
      # probably an issue where we were unable to connect with wild apricot at all
      return true
    end
    contact = response[:Contacts]
    logger.warn(contact)
    if !contact.blank?
      contact = contact[0]
      logger.warn(contact)
      if contact[:Status] && contact[:Status] == "Active"
        logger.warn("active")
        return true
      else
        logger.warn("not active")
        return false
      end
    else
      logger.warn("no user found")
      return false
    end
  end


  def after_database_authentication
    if !self.admin?
      if self.check_paid_status
        self.role = 'paid_user'
      else
        self.role = 'unpaid_user'
      end
    end
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
