module CerberusCore::Concerns::HasCollections
  extend ActiveSupport::Concern

  included do 
    # Records the model names for folder type classes that can have an instance
    # of this collection as their parent.  So for a collection class that could only
    # have other instances of itself as children, we would write:
    # Collection.has_collection_types ["Collection"]
    # A collection that has itself and a subtly different CollectionOther child would
    # define
    # Collection.has_collection_types ["Collection", "CollectionOther"]
    @collection_types = [] 

    def self.collection_types
      @collection_types || []
    end

    def self.has_collection_types(arry)
      @collection_types = arry 
    end
  end
end 