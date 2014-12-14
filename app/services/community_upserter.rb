class CommunityUpserter
  include Concerns::Upserter

  def upsert 
    begin 
      if Nid.exists_by_nid?(params[:nid])
        community = Community.find_by_nid(params[:nid])
        update_metadata(community)
        community.save!
      else
        community = Community.new
        community.nid = params[:nid]
        update_metadata(community)

        community.save!
        community.community = Community.root_community
        community.save!
      end
    rescue => e
      ExceptionNotifier.notify_exception(e, :data => { :params => params })
      raise e
    end  
  end

  private 

    def update_metadata(community) 
      community.mods.title = params[:title]
      community.depositor = params[:depositor]
      community.project_members = params[:members] 
      community.drupal_access = params[:access]
    end
end
