class TapasObjectCreationJob
  attr_accessor :params, :klass

  def initialize(object_params, object_class)
    self.params = object_params 
    self.klass  = object_class
  end

  def run 
    "#{klass}CreatorService".constantize.create_record(params)
  end
end