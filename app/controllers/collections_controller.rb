class CollectionsController < ApplicationController
  include ApiAccessible

  def create
    job = TapasObjectCreationJob.new(params, "Collection")
    TapasRails::Application::Queue.push(job)
    @response[:message] = "Collection is being processed"
    pretty_json(202) and return 
  end
end
