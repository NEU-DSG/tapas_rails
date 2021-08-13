module CerberusCore::Concerns::HasCommunities
  extend ActiveSupport::Concern 

  included do 
    @community_types = [] 

    def self.community_types 
      @community_types || [] 
    end

    def self.has_community_types(arry) 
      @community_types = arry 
    end
  end
end