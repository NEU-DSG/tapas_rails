class CollectionsController < ApplicationController
  include ApiAccessible

  def upsert 
    TapasRails::Application::Queue.push TapasObjectUpsertJob.new params 
    @response[:message] = "Collection upsert accepted" 
    pretty_json(202) and return 
  end
end
