class UpsertProject
  include Upserter

  def execute
    begin
      project = Project.find_by_did(params[:did])
      if project
        update_metadata! project
      else
        project = Project.new(:did => params[:did])
        project.depositor = params[:depositor]
        update_metadata! project
        project.save!
        project.project = Project.root_project
      end

      if params[:thumbnail]
        project.add_thumbnail(:filepath => params[:thumbnail])
        project.save!
      end
      upsert_logger.info("project upsert for #{project.pid} has did #{project.did}")
    rescue => e
      ExceptionNotifier.notify_exception(e, :data => { :params => params })
      raise e
    ensure
      FileUtils.rm(params[:thumbnail]) if should_delete_file? params[:thumbnail]
    end
  end

  private

    def update_metadata!(project)
      # project.mods.title = params[:title] if params.has_key? :title
      project.DC.title = params[:title] if params.has_key? :title
      # project.mods.abstract = params[:description] if params.has_key? :description
      project.DC.description = params[:description] if params.has_key? :description
      project.match_dc_to_mods
      project.project_members = params[:members] if params.has_key? :members
      project.properties.project_members = params[:members] if params.has_key? :members
      project.drupal_access = params[:access] if params.has_key? :access
      project.mass_permissions = params[:access] if params.has_key? :access
      project.properties.project_members.each do |p|
        project.rightsMetadata.permissions({person: p}, 'edit')
      end
      project.save!
    end

    def upsert_logger
      @@upsert_logger ||= Logger.new("#{Rails.root}/log/#{Rails.env}_upsert.log")
    end
end
