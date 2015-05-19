class CommunityUpserter
  include Concerns::Upserter

  def upsert 
    begin 
      if Did.exists_by_did?(params[:did])
        community = Community.find_by_did(params[:did])
        update_metadata(community)
        community.save!
      else
        community = Community.new
        community.did = params[:did]
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
      community.mods.title = params[:title] if params[:title].present?
      community.mods.abstract = params[:description] if params[:description].present?
      community.depositor = params[:depositor] if params[:depositor].present?
      community.project_members = params[:members] if params[:members].present?
      community.drupal_access = params[:access] if params[:access].present?
    end
end
