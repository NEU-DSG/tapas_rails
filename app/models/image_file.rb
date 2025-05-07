class ImageFile < ApplicationRecord
  # associations
  belongs_to :imageable, polymorphic: true
  # belongs_to :depositor, class_name: "User"
  has_one_attached :file

  # validations
  validates_presence_of :title, :depositor_id
  validate :file_format

  def process_image_data
    URI.open(image_url)
  end

  def file_format
    return unless file.attached?

    errors.add(:image, "must be a JPEG, JPG, GIF, or PNG file") unless content_type.in?(%w[image/jpeg image/jpg image/gif image/png])
  end
end
