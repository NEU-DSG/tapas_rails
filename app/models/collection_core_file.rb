class CollectionCoreFile < ApplicationRecord
  belongs_to :collection
  belongs_to :core_file

  validates :core_file_id, uniqueness: { scope: collection_id }
end
