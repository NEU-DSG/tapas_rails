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

    valid_types = %w[
      image/jpeg
      image/gif
      image/png
      image/svg+xml
      application/pdf
    ]

    unless content_type.in?(valid_types)
      errors.add(:image, "must be a JPEG, GIF, PNG, SVG, or PDF file")
    end
  end
end
