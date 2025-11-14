class ImageFile < ApplicationRecord
  # associations
  belongs_to :imageable, polymorphic: true
  has_one_attached :file

  # validations
  validates_presence_of :title, :depositor_id
  validate :file_format

  # constants
  VALID_FILE_TYPES = %w[
      image/jpeg
      image/gif
      image/png
      image/svg+xml
    ].freeze

  # should this list include .gif?
  VALID_FILE_EXTENSIONS = %w[jpg png jpeg].freeze

  def process_image_data
    URI.open(image_url)
  end

  def file_format
    return unless file.attached?

    valid_types = imageable_type.eql?('CoreFile') ? [VALID_FILE_TYPES, 'application/pdf'].flatten : VALID_FILE_TYPES

    unless file.content_type.in?(valid_types)
      errors.add(:image, "must be a JPEG, GIF, PNG, SVG, or PDF file")
    end
  end
end
