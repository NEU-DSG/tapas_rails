class CommunitiesController < ApplicationController
  include ApiAccessible

  def upsert 
    TapasRails::Application::Queue.push TapasObjectUpsertJob.new params
    @response[:message] = "Community upsert in progress" 
    pretty_json(202) and return
  end 

  def destroy
    community = Community.find_by_did params[:did] 

    if community
      community.descendents.each { |descendent| descendent.destroy }
      community.destroy 
      @response[:message] = "Project successfully destroyed"
      pretty_json(200) and return
    else
      @response[:message] = "Project not found with Drupal ID #{params[:did]}"
      pretty_json(404) and return
    end
  end
end
