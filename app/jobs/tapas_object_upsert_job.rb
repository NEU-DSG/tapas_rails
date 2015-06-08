class TapasObjectUpsertJob 
  attr_accessor :params

  def initialize(params)
    @params = params 
  end

  def run 
    model = params[:controller].singularize.camelcase
    "Upsert#{model}".constantize.upsert(params)
  end
end
