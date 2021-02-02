class CommunitiesInstitution < ActiveRecord::Base
  belongs_to :community, inverse_of: :communities_institutions
  belongs_to :institution, inverse_of: :communities_institutions
end
