class CommunitiesInstitution < ActiveRecord::Base
  belongs_to :community
  belongs_to :institution
end
