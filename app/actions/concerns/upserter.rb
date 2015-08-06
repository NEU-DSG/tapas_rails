module Concerns::Upserter
  extend ActiveSupport::Concern 

  included do 
    attr_reader :params 

    def self.execute(params)
      self.new(params).execute
    end
  end

  def initialize(params)
    @params = params 
  end
end
