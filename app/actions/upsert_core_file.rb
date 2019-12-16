require "zip"

class UpsertCoreFile
  include Concerns::Upserter
  attr_accessor :core_file, :update_type, :file_type

  def initialize(params)
    @params = params
  end

  def execute
    begin
      # logger.info("params in job")
      # logger.info(params)
      if params[:did] && Did.exists_by_did?(params[:did])
        self.core_file = CoreFile.find_by_did(params[:did])
      else
        self.core_file = CoreFile.create(:depositor => params[:depositor])
        core_file.save!
        core_file.did = core_file.pid
      end
      # logger.info(core_file)

      core_file.mark_upload_in_progress!
      core_file.depositor = params[:depositor]

      # Validate TEI
      tei_errors = Exist::ValidateTei.execute params[:tei]
      if tei_errors.any?
        core_file.errors_display << 'Your TEI File was invalid.'\
          '  Please reupload once you have fixed all errors.'
        core_file.errors_display = core_files.errors_display + tei_errors
        core_file.mark_upload_failed!
        return false
      end

      opts = {}
      opts[:authors] = params[:display_authors]
      opts[:date] = params[:display_date]
      opts[:title] = params[:display_title]
      opts[:contributors] = params[:display_contributors]

      if mods_needs_updating
        mods_record = Exist::GetMods.execute(params[:tei], opts)
        core_file.mods.content = mods_record

        # Rewrite did to mods after update
        core_file.did = params[:did]? params[:did] : core_file.pid
        # Rewrite identifier to mods after update
        core_file.mods.identifier = core_file.pid
      end

      core_file.drupal_access = params[:access] if params.has_key? :access
      core_file.mass_permissions = params[:access] if params.has_key? :access
      core_file.mass_permissions = params[:mass_permissions] if params.has_key? :mass_permissions

      update_associations!

      if params[:tei].present?
        Content::UpsertTei.execute(core_file, params[:tei])
      end

      upsert_logger.info(params)
      if params[:support_files].present?
        # extract files to a hash of temporary directories
        all_files = ExtractFiles.execute(params[:support_files])
        upsert_logger.info(all_files)
        @directory = all_files[:directory]

        thumbnail = all_files[:thumbnail]
        if thumbnail.present?
          Content::UpsertThumbnail.execute(core_file, thumbnail)
        end

        page_imgs = all_files[:page_images]
        if page_imgs.present?
          Content::UpsertPageImages.execute(core_file, page_imgs)
        end
      end

      core_file.save!

      # Correct reading interface generation relies on support content being
      # in place, so this needs to happen down here.
      if params[:tei].present?
        Content::UpsertReadingInterface.execute_all(core_file, params[:tei])
      end

      core_file.save!
      upsert_logger.info("CoreFile upsert for #{core_file.pid} has did #{core_file.did}")

      Exist::IndexCoreFile.execute(core_file, params[:tei], opts)

      if core_file.is_ography?
        TapasRails::Application::Queue.push(RebuildCommunityReadingInterfaceJob.new(core_file.project.pid))
        #if it is an ography then run a job to rebuild all the reading interfaces in this project
      end

      core_file.mark_upload_complete!
    rescue => e
      ExceptionNotifier.notify_exception(e, :data => { :params => params })

      # core_file.set_default_display_error
      # core_file.set_stacktrace_message(e)
      # core_file.mark_upload_failed!
      raise e
    ensure
      FileUtils.rm params[:tei] if should_delete_file? params[:tei]
      FileUtils.rm params[:support_files] if should_delete_file? params[:support_files]
      FileUtils.rm_rf @directory if @directory
    end
  end

  def update_associations!
    # upsert_logger.info("starting update_associations")
    if params[:collection_dids].is_a?(Array)
      collections = params[:collection_dids].map do |did|
        if Collection.exists?(did)
          Collection.find(did)
        elsif Collection.exists_by_did?(did)
          Collection.find_by_did(did)
        else
          raise "Collection does not exist"
        end
      end
    end
    # logger.info("we are in update associations")
    # logger.info(collections)

    # In the case where new collection_dids and new file_types are provided,
    # overwrite both the ography types and the collection memberships this
    # record declares
    if params[:file_types].is_a?(Array) && params[:collection_dids].is_a?(Array)
      core_file.clear_ographies!
      core_file.collections = collections
      params[:file_types].each do |ogmethod|
        if !ogmethod.blank?
          core_file.send(:"#{ogmethod}_for=", collections)
        end
      end
    # In the case where only collection_dids are provided, update the
    # collections association to use the new collections AND make sure
    # that any previous ography relationships that this core_file had
    # are updated to point at the new set of collections
    elsif params[:collection_dids].is_a?(Array)
      core_file.collections = collections
      CoreFile.all_ography_read_methods.each do |ography|
        if core_file.send(ography).any?
          core_file.send(:"#{ography}=", collections)
        end
      end
    # in case where its just one string of a collection
    elsif params[:collection_dids].is_a?(String)
      col = Collection.find_by_did(params[:collection_dids])
      core_file.collections = [col]
    # In the case where only file_types are provided, update which
    # ography relationships are declared but use the collections
    # that the CoreFile is already a member of
    elsif params[:file_types].is_a?(Array)
      old_collections = core_file.collections.to_a
      core_file.clear_ographies!
      params[:file_types].each do |ogmethod|
        if !ogmethod.blank?
          core_file.send(:"#{ogmethod}_for=", old_collections)
        end
      end
    else
      # logger.info("none of the above")
      upsert_logger.info(params)
    end
    core_file.save!
    # logger.info("done with associations")
    # logger.info(core_file.collections)
    # logger.info(params)
  end

  private
    def mods_needs_updating
      keys = [:tei, :display_authors, :display_contributors, :display_date,
              :display_title]
      keys.any? { |key| params[key].present? }
    end

    def upsert_logger
      @@upsert_logger ||= Logger.new("#{Rails.root}/log/#{Rails.env}_upsert.log")
    end
end
