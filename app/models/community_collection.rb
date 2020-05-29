class CommunityCollection < ActiveRecord::Base
  belongs_to :collection
  belongs_to :community
end
