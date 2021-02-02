class CollectionsCoreFile < ActiveRecord::Base
  belongs_to :collection, inverse_of: :collections_core_files
  belongs_to :core_file, inverse_of: :collections_core_files
end
