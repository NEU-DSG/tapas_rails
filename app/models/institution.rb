class Institution < ActiveRecord::Base
  attr_accessible :name, :description, :image, :address, :latitude, :longitude, :url if Rails::VERSION::MAJOR < 4
  validates_presence_of :name

  has_many :users
  has_many :communities_institutions
  has_many :communities, through: :communities_institutions
end
