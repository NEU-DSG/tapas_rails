class CommunitiesController < ApplicationController
  include ApiAccessible

  def create
    job = TapasObjectCreationJob.new(params, "Community")
    TapasRails::Application::Queue.push(job)
    @response[:message] = "Community being created."
    pretty_json(202) and return
  end
end
