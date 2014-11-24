class TapasObjectCreationJob
  attr_accessor :params

  def initialize(params)
    @params = params 
  end

  def run 
    model_name = params[:controller].singularize.camelcase
    "#{model_name}Creator".constantize.create_record(params)
  end
end
