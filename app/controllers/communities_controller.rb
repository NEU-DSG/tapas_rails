class CommunitiesController < ApplicationController
  include ApiAccessible

  before_action :load_community_by_nid, :except => [:create]

  def create
    TapasRails::Application::Queue.push TapasObjectCreationJob.new params
    @response[:message] = "Community being created."
    pretty_json(202) and return
  end

  def nid_update 
    if params[:members]
      @community.project_members = params[:members]
    end

    @community.save!
    @response[:message] = "Community updated successfully."
    pretty_json(200) and return 
  end

  private 
    def load_community_by_nid
      @community = Community.find_by_nid(params[:nid])
      @community = Community.find @community.id
    end
end
