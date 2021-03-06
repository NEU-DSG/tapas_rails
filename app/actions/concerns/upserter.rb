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

  def should_delete_file?(filepath)
    filepath.present? && File.exists?(filepath) && filepath.include?('tmp')
  end
end
