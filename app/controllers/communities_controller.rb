class CommunitiesController < ApplicationController
  include ApiAccessible

  def upsert 
    TapasRails::Application::Queue.push TapasObjectUpsertJob.new params
    @response[:message] = "Community upsert in progress" 
    pretty_json(202) and return
  end 
end
