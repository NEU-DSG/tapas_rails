module CerberusCore::BaseModels
  # Implements the notion of a collection holding core records and other
  # collections.  Collections may belong to Communities but cannot have 
  # Communities as children. 
  class Collection < ActiveFedora::Base
    include CerberusCore::Concerns::ParanoidRightsValidation
    include CerberusCore::Concerns::PropertiesDatastreamDelegations
    include CerberusCore::Concerns::ParanoidRightsDatastreamDelegations
    include CerberusCore::Concerns::Relatable
    include CerberusCore::Concerns::Traversals
    include CerberusCore::Concerns::HasCoreFiles 
    include CerberusCore::Concerns::HasCollections
    include CerberusCore::Concerns::AutoMintedPid

    has_metadata name: 'DC', type: CerberusCore::Datastreams::DublinCoreDatastream
    has_metadata name: 'rightsMetadata', type: CerberusCore::Datastreams::ParanoidRightsDatastream
    has_metadata name: 'properties', type: CerberusCore::Datastreams::PropertiesDatastream
    has_metadata name: 'mods', type: CerberusCore::Datastreams::ModsDatastream

    # All querying logic assumes that collections are related to communities
    # via the is_member_of relationship.  Using this method to define that
    # relationship enforces this constraint.  See ContentObject for a 
    # description of arguments.
    def self.parent_community_relationship(relationship_name, parent_class = nil)
      self.relation_asserter(:belongs_to, 
                             relationship_name, 
                             :is_member_of, 
                             parent_class)
    end

    # All querying logic assumes that collections are related to their 
    # parent collections via the is_member_of relationship.  Using this 
    # method to define that relationship enforces this constraint.  See 
    # ContentObject for a description of arguments.
    def self.parent_collection_relationship(relationship_name, parent_class = nil) 
      self.relation_asserter(:belongs_to, 
                             relationship_name, 
                             :is_member_of, 
                             parent_class)
    end
  end
end
