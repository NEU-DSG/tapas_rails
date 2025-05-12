require "net/http"
require "uri"

class User < ApplicationRecord
  include Blacklight::User

  has_one_attached :image_file
  has_one :image_file, as: :imageable
  has_many :project_members
  has_many :projects, through: :project_members

  #TODO: add logic to update role when user creates or joins an existing project or collection

  # delegate :image, to: :image_file, allow_nil: true

  # if Blacklight::Utils.needs_attr_accessible?
  #   attr_accessible :email, :password, :password_confirmation, :name, :role, :bio, :account_type
  # end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable
         # :confirmable; TODO: add this again after smtp is configured

  delegate :can?, :cannot?, :to => :ability


  def api_key=(api_key)
    @api_key = Digest::SHA512.hexdigest api_key
    self.encrypted_api_key = @api_key
  end

  def role
    ProjectMember.find_by_user_id(id).role ||= 'reader'
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
    admin_at.nil? ? false : true
  end

  def self.find_by_user_key(key)
    self.send("find_by_nuid".to_sym, key)
  end

  # def forem_name
  #   self.name
  # end
  #ß
  # def forem_email
  #   self.email
  # end

  # paid accounts are deprecated
  # def check_paid_status
  #   # FIXME: we can't use pluot, as it's too out of date
  #   # re-implement this with our own Wild Apricot REST wrapper?
  #   return true
  #   # api_key = ENV['WILD_APRICOT_API_KEY']
  #   # aid = 66796
  #   # # Pluot.api_key = api_key
  #   # # Pluot.account_id = aid
  #   # logger.warn("e-Mail eq #{self.email}")
  #   # begin
  #   #   response = Pluot.contacts.filter("e-Mail eq #{self.email}")
  #   # rescue Faraday::ConnectionFailed => e
  #   #   print e
  #   #   return false
  #   # end
  #   # logger.warn(response)
  #   # if response.blank?
  #   #   # probably an issue where we were unable to connect with wild apricot at all
  #   #   return true
  #   # end
  #   # contact = response[:Contacts]
  #   # logger.warn(contact)
  #   # if !contact.blank?
  #   #   contact = contact[0]
  #   #   logger.warn(contact)
  #   #   if contact[:Status] && contact[:Status] == "Active"
  #   #     logger.warn("active")
  #   #     return true
  #   #   else
  #   #     logger.warn("not active")
  #   #     return false
  #   #   end
  #   # else
  #   #   logger.warn("no user found")
  #   #   return false
  #   # end
  # end


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
