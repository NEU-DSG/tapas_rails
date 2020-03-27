module CerberusCore::BaseModels
  # Implements the notion of a community, which is an object describing
  # a project with affiliated users, collections, and records.  Communities
  # may belong only to other communities via the has_affiliation relationship.
  class Community < ActiveFedora::Base 
    include CerberusCore::Concerns::PropertiesDatastreamDelegations
    include CerberusCore::Concerns::ParanoidRightsDatastreamDelegations
    include CerberusCore::Concerns::Relatable
    include CerberusCore::Concerns::Traversals
    include CerberusCore::Concerns::HasCollections
    include CerberusCore::Concerns::HasCommunities
    include CerberusCore::Concerns::HasCoreFiles
    include CerberusCore::Concerns::AutoMintedPid

    has_metadata name: 'DC', type: CerberusCore::Datastreams::DublinCoreDatastream
    has_metadata name: 'rightsMetadata', type: CerberusCore::Datastreams::ParanoidRightsDatastream
    has_metadata name: 'properties', type: CerberusCore::Datastreams::PropertiesDatastream
    has_metadata name: 'mods', type: CerberusCore::Datastreams::ModsDatastream

    # We assume that communities are related to their parent communities via 
    # the has_affiliation relationship.  Using this method to define that
    # relationship enforces this constraint.  See ContentObject for an arg 
    # description.
    def self.parent_community_relationship(relationship_name, parent_class = nil)
      self.relation_asserter(:belongs_to, 
                             relationship_name, 
                             :has_affiliation, 
                             parent_class) 
    end
  end
end