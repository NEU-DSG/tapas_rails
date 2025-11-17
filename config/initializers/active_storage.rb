# ActiveStorage configuration
# Routes ActiveStorage jobs to dedicated queues for better monitoring and resource allocation

Rails.application.config.to_prepare do
  # Route ActiveStorage analysis jobs to dedicated queue
  # These jobs analyze uploaded files for content type, dimensions, etc.
  ActiveStorage::AnalyzeJob.queue_as :active_storage if defined?(ActiveStorage::AnalyzeJob)

  # Route ActiveStorage purge jobs to dedicated queue
  # These jobs delete files from storage when records are destroyed
  ActiveStorage::PurgeJob.queue_as :active_storage if defined?(ActiveStorage::PurgeJob)

  # Note: In development with analyze disabled (config.active_storage.analyze = false),
  # AnalyzeJob won't be enqueued, but configuration is still safe
end
