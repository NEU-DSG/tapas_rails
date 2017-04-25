class Page < ActiveRecord::Base
  extend FriendlyId
  include Bootsy::Container

  attr_accessible :title, :content, :slug if Rails::VERSION::MAJOR < 4
  validates_presence_of :title, :content, :slug
  validates :slug, uniqueness: { case_sensitive: false }
  friendly_id :slug, use: :slugged
end
