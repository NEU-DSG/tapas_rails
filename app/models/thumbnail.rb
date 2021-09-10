class Thumbnail < ActiveRecord::Base
  belongs_to :owner, polymorphic: true

  validates :url, presence: true
end
