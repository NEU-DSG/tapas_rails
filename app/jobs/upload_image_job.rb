class UploadImageJob < ApplicationJob
  # review carrierwave gem configuration for uploading images; it will need to be set up to store images in AWS S3 bucket
  queue_as :default

  def perform(*args)
    # Do something later
  end
end
