class NewsItem < ActiveRecord::Base
  extend FriendlyId

  attr_accessible :title, :content, :slug, :publish, :author, :tags if Rails::VERSION::MAJOR < 4
  validates_presence_of :title, :content, :slug
  validates :slug, uniqueness: { case_sensitive: false }
  friendly_id :slug, use: :slugged

end
