class CommunityCollection < ActiveRecord::Base
  belongs_to :collection, inverse_of: :community_collections
  belongs_to :community, inverse_of: :community_collections,
end
