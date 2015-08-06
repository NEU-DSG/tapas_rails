require "zip"

class UpsertCoreFile
  include Concerns::Upserter
  attr_accessor :core_file, :update_type, :file_type

  def initialize(params)
    @params = params
  end

  def execute
    begin 
      if Did.exists_by_did?(params[:did])
        self.core_file = CoreFile.find_by_did(params[:did]) 
      else
        self.core_file = CoreFile.create(:did => params[:did], 
                                         :depositor => params[:depositor])
      end

      if mods_needs_updating
        author = params[:display_author]
        contributors = params[:display_contributors]
        mods_record = Exist::GetMods.execute(params[:tei])
        core_file.mods.content = mods_record
        # Rewrite did to mods after update
        core_file.did = params[:did]
        # Rewrite identifier to mods after update
        core_file.mods.identifier = core_file.pid
      end

      update_associations!

      if params[:tei].present?
        Content::UpsertTei.execute(core_file, params[:tei])
        Content::UpsertReadingInterface.execute_all(core_file, params[:tei])
      end

      if params[:support_files].present?
        # extract files to a hash of temporary directories
        all_files = ExtractFiles.execute(params[:support_files])
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
    rescue => e 
      ExceptionNotifier.notify_exception(e, :data => { :params => params })
      raise e 
    ensure
      FileUtils.rm params[:tei] if params[:tei] && File.exists?(params[:tei])
      FileUtils.rm params[:support_files] if params[:support_files]
      FileUtils.rm_rf @directory if @directory
    end
  end

  def update_associations!
    if params[:collection_dids].present?
      collections = params[:collection_dids].map do |did|
        Collection.find_by_did(did)
      end
    end

    # In the case where new collection_dids and new file_types are provided, 
    # overwrite both the ography types and the collection memberships this
    # record declares
    if params[:file_types].present? && params[:collection_dids].present?
      core_file.clear_ographies!
      core_file.collections = collections
      params[:file_types].each do |ography|
        core_file.send(:"#{ography}_for=", collections)
      end
    # In the case where only collection_dids are provided, update the
    # collections association to use the new collections AND make sure
    # that any previous ography relationships that this core_file had
    # are updated to point at the new set of collections
    elsif params[:collection_dids].present?
      core_file.collections = collections 
      CoreFile.all_ography_types.each do |ography|
        if core_file.send(ography).any?
          core_file.send(:"#{ography}=", collections)
        end
      end
    # In the case where only file_types are provided, update which 
    # ography relationships are declared but use the collections 
    # that the CoreFile is already a member of
    elsif params[:file_types].present?
      old_collections = core_file.collections.to_a
      core_file.clear_ographies!
      params[:file_types].each do |ography|
        core_file.send(:"#{ography}_for=", old_collections)
      end
    end

    core_file.save!
  end

  private
    def mods_needs_updating
      params[:tei].present? || params[:display_authors].present? ||
        params[:display_contributors].present?
    end
end

