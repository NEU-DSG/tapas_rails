class Page < ActiveRecord::Base
  extend FriendlyId
  attr_accessible :title, :content, :slug if Rails::VERSION::MAJOR < 4
  validates_presence_of :title, :content, :slug
  friendly_id :slug, use: :slugged
end
