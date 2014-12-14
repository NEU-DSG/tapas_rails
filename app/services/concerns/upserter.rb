module Concerns::Upserter
  extend ActiveSupport::Concern 

  included do 
    attr_reader :params 

    def initialize(params)
      @params = params 
    end

    def self.upsert(params)
      self.new(params).upsert 
    end
  end
end
