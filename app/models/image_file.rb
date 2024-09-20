class ImageFile < ActiveRecord::Base
  # associations
  belongs_to :imageable, polymorphic: true

  has_one_attached :file

  belongs_to :depositor, class_name: "User"

  # validations
  validates_presence_of :title, :depositor_id
  # validate :file_format
  #
  # def file_format
  #   return unless file.attached?
  #
  #   errors.add(:image, "must be a JPEG, JPG, GIF, or PNG file") unless image.content_type.in?(%w[image/jpeg image/jpg image/gif image/png])
  # end
end
