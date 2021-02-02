class User < ActiveRecord::Base
  include Discard::Model

  require 'net/http'
  require 'uri'

  mount_uploader :avatar, AvatarUploader
  validates_integrity_of :avatar

  # TODO: revisit the validates name issue preventing user signup and migration
  # validates :name, presence: true

  validates :username, presence: true, uniqueness: true
  before_validation :ensure_unique_username, on: :create

  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email, :password, :password_confirmation, :name, :role, :bio, :account_type
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  delegate :can?, :cannot?, :to => :ability

  belongs_to :institution

  has_many :community_members
  has_many :communities, through: :community_members
  has_many :core_files_users
  has_many :core_files, through: :core_files_users

  ACCOUNT_TYPES = %w[free teic teic_inst]

  def api_key=(api_key)
    @api_key = Digest::SHA512.hexdigest api_key
    self.encrypted_api_key = @api_key
  end

  # https://github.com/jhawthorn/discard#working-with-devise
  def active_for_authentication?
    super && !discarded_at
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
    id.to_s
  end

  def role
    if admin?
      'admin'
    else
      'user'
    end
  end

  def admin=(integer_bool)
    if integer_bool.to_i.zero?
      update(admin_at: nil)
    else
      update(admin_at: Time.zone.now)
    end
  end

  def admin?
    !admin_at.nil?
  end

  def paid=(integer_bool)
    if integer_bool.to_i.zero?
      update(paid_at: nil)
    else
      update(paid_at: Time.zone.now)
    end
  end

  def paid_user?
    !paid_at.nil?
  end

  def unpaid_user?
    paid_at.nil?
  end

  def self.find_by_user_key(key)
    send('find_by_nuid'.to_sym, key)
  end

  def forem_name
    name
  end

  def forem_email
    email
  end

  def check_paid_status
    # FIXME: we can't use pluot, as it's too out of date
    # re-implement this with our own Wild Apricot REST wrapper?
    return true
    # api_key = ENV['WILD_APRICOT_API_KEY']
    # aid = 66796
    # # Pluot.api_key = api_key
    # # Pluot.account_id = aid
    # logger.warn("e-Mail eq #{self.email}")
    # begin
    #   response = Pluot.contacts.filter("e-Mail eq #{self.email}")
    # rescue Faraday::ConnectionFailed => e
    #   print e
    #   return false
    # end
    # logger.warn(response)
    # if response.blank?
    #   # probably an issue where we were unable to connect with wild apricot at all
    #   return true
    # end
    # contact = response[:Contacts]
    # logger.warn(contact)
    # if !contact.blank?
    #   contact = contact[0]
    #   logger.warn(contact)
    #   if contact[:Status] && contact[:Status] == "Active"
    #     logger.warn("active")
    #     return true
    #   else
    #     logger.warn("not active")
    #     return false
    #   end
    # else
    #   logger.warn("no user found")
    #   return false
    # end
  end

  def ensure_unique_username
    base = username || (name || 'anonymous').parameterize(separator: '', preserve_case: true)
    attempt = base
    count = 1

    loop do
      if User.where(username: attempt).empty?
        self.username = attempt
        return
      else
        count += 1
        attempt = "#{base}#{count}"
      end
    end
  end

  private

  def generate_api_key
    key = Devise.friendly_token

    @api_key = Digest::SHA512.hexdigest key

    if User.where(encrypted_api_key: @api_key)
      generate_api_key
    else
      self.encrypted_api_key = @api_key
    end
  end
end
