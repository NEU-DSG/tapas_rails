module Concerns::TapasObjectCreator 
  extend ActiveSupport::Concern

  included do 
    attr_accessor :params 

    def initialize(params)
      @params = params 
    end

    def self.create_record(params) 
      self.new(params).create_record 
    end
  end
end
