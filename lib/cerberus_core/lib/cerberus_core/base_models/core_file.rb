module CerberusCore::BaseModels
  # This module implements the notion of a core record.  
  # Core records are fedora objects that hold 
  # metadata related to any number of content objects (defined in 
  # CerberusCore::ContentObject) attached to them via the standard isPartOf
  # relationship.  Core records can belong to collections.
  class CoreFile < ActiveFedora::Base
    include CerberusCore::Concerns::ParanoidRightsValidation
    include CerberusCore::Concerns::ParanoidRightsDatastreamDelegations
    include CerberusCore::Concerns::PropertiesDatastreamDelegations
    include CerberusCore::Concerns::Relatable
    include CerberusCore::Concerns::Traversals
    include CerberusCore::Concerns::AutoMintedPid

    before_destroy :destroy_content_objects

    # Default datastreams 
    has_metadata name: "DC", type: CerberusCore::Datastreams::DublinCoreDatastream
    has_metadata name: "mods", type: CerberusCore::Datastreams::ModsDatastream
    has_metadata name: "properties", type: CerberusCore::Datastreams::PropertiesDatastream
    has_metadata name: "rightsMetadata", type: CerberusCore::Datastreams::ParanoidRightsDatastream

    # All querying logic assumes that core records are related to their parent 
    # collections via the is_member_of relationship.  Using this method to define
    # that relationship enforces this constraint.  See ContentObject for a
    # description of the arguments.
    def self.parent_collection_relationship(relationship_name, parent_class = nil)
      self.relation_asserter(:belongs_to, 
                             relationship_name, 
                             :is_member_of, 
                             parent_class)
    end

    # Destroy every content object attached to this CoreRecord
    def destroy_content_objects
      content_objects.map { |x| x.destroy } 
    end
  end
end
