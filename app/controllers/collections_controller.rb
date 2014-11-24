class CollectionsController < ApplicationController
  include ApiAccessible

  def create
    TapasRails::Application::Queue.push TapasObjectCreationJob.new(params)
    @response[:message] = "Collection is being processed"
    pretty_json(202) and return 
  end
end
