class TapasObjectCreationJob
  attr_accessor :params, :klass

  def initialize(request_params, object_class)
    self.params = request_params 
    self.klass  = object_class
  end

  def run 
    TapasObjectCreatorService.create_record(params, klass)
  end
end