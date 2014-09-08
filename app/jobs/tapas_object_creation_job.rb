class TapasObjectCreationJob
  attr_accessor :params, :klass

  def initialize(request_params, object_class)
    self.params = request_params 
    self.klass  = object_class
  end

  def run 
    "#{klass}CreatorService".constantize.create_record(params)
  end
end