class UpsertCommunity
  include Concerns::Upserter

  def execute
    begin
      community = Community.find_by_did(params[:did])
      if community
        update_metadata! community
      else
        community = Community.new(:did => params[:did])
        community.depositor = params[:depositor]
        community.save!
        community.community = Community.root_community
        update_metadata! community
      end

      if params[:thumbnail]
        community.add_thumbnail(:filepath => params[:thumbnail])
        community.save!
      end
      upsert_logger.info("Community upsert for #{community.pid} has did #{community.did}")
    rescue => e
      ExceptionNotifier.notify_exception(e, :data => { :params => params })
      raise e
    ensure
      FileUtils.rm(params[:thumbnail]) if should_delete_file? params[:thumbnail]
    end
  end

  private

    def update_metadata!(community)
      community.mods.title = params[:title] if params.has_key? :title
      community.mods.abstract = params[:description] if params.has_key? :description
      community.project_members = params[:members] if params.has_key? :members
      community.drupal_access = params[:access] if params.has_key? :access
      community.save!
    end

    def upsert_logger
      @@upsert_logger ||= Logger.new("#{Rails.root}/log/#{Rails.env}_upsert.log")
    end
end
