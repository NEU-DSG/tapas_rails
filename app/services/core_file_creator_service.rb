class CoreFileCreatorService
  attr_accessor :params

  def initialize(params)
    @params = params
  end

  def self.create_record(params) 
    self.new(params).create_record
  end

  def create_record 
    #TODO
  end
end