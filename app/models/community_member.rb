class CommunityMember < ActiveRecord::Base
  belongs_to :community
  belongs_to :user

  validates :user, uniqueness: { scope: :community }
end
