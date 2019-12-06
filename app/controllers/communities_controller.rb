class CommunitiesController < ApplicationController
  include ApiAccessible

  def upsert
    if params[:thumbnail]
      params[:thumbnail] = create_temp_file(params[:thumbnail])
    end

    TapasRails::Application::Queue.push TapasObjectUpsertJob.new params
    @response[:message] = "Community upsert in progress"
    pretty_json(202) and return
  end

  # def destroy
  #   @community.descendents.each { |descendent| descendent.destroy }
  #   @community.destroy
  #   @response[:message] = "Project successfully destroyed"
  #   pretty_json(200) and return
  # end
end
