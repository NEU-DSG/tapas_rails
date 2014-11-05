module Concerns::TapasObjectCreator 
  extend ActiveSupport::Concern

  included do 
    attr_reader :params 
    attr_accessor :response

    def initialize(params)
      @params = params 
      @response = {}
    end

    def self.create_record(params) 
      self.new(params).create_record 
    end
  end
end
