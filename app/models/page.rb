class Page < ActiveRecord::Base
  extend FriendlyId

  attr_accessible :title, :content, :slug, :publish, :submenu if Rails::VERSION::MAJOR < 4
  validates_presence_of :title, :content, :slug
  validates :slug, uniqueness: { case_sensitive: false }
  friendly_id :slug, use: :slugged

end
