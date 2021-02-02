################################################################################
#
#  exist_sync.rake
#  Sync the XML content from the files listed in TAPAS database to eXist
#
# This task will perform an ETL process to sync content from the Rails MySQL
# database so that all XML data in TAPAS can be added into the eXist
# database while still using MySQL as a ground source of truth.
#
#  - Usage:
#      bin/rake exist:sync
#
################################################################################

# desc "Sync all XML content from TAPAS to eXist"
# namespace :exist do
#   task sync: [:environment] do
#     # If necessary, remove all content from eXist
#     # This method would need to be added to the ExistService
#     ExistService.delete_all
#
#     # Get all data from the CoreFile model
#     CoreFile.all.each do |core_file|
#       ExistService.post(...data_from_core_file...)
#     end
#
#   end
# end
