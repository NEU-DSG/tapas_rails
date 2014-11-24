class CommunitiesController < ApplicationController
  include ApiAccessible

  def create
    TapasRails::Application::Queue.push TapasObjectCreationJob.new params
    @response[:message] = "Community being created."
    pretty_json(202) and return
  end
end
