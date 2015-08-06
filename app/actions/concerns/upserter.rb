module Concerns::Upserter
  extend ActiveSupport::Concern 

  included do 
    attr_reader :params 

    def initialize(params)
      @params = params 
    end

    def self.execute(params)
      self.new(params).execute
    end
  end
end
