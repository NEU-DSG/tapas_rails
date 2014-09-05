class TapasObjectCreatorService 
  attr_accessor :params, :klass

  def initialize(params, klass) 
    self.params = params 
    self.klass  = klass 
  end 

  def self.create_record 
    TapasObjectCreatorService.new(params, klass).create_record 
  end

  def create_record
    record = klass.constantize.new
  end
end