class CommunityCommunity < ActiveModel::Base
  belongs_to :community
  belongs_to :parent_community, class_name: 'Community'
end
