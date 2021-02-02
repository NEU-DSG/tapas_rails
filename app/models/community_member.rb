class CommunityMember < ActiveRecord::Base
  belongs_to :community, inverse_of: :community_members
  belongs_to :user, inverse_of: :community_members

  validates :user, uniqueness: { scope: :community }
end
