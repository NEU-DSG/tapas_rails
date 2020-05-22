class Institution < ActiveRecord::Base
  attr_accessible :name, :description, :image, :address, :latitude, :longitude, :url if Rails::VERSION::MAJOR < 4
  validates_presence_of :name

  has_many :users
  belongs_to :community
end
