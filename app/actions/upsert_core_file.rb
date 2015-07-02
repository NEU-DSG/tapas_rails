require "zip"

class UpsertCoreFile
  include Concerns::Upserter
  attr_accessor :core_file # Saves the core file this upserter is handling

  def initialize(params)
    @params = params
  end

  def upsert
    begin 
      if Did.exists_by_did?(params[:did])
        self.core_file = CoreFile.find_by_did(params[:did])
      else
        self.core_file = CoreFile.create(:did => params[:did])
      end

      update_metadata!

      if params[:tei] 
        UpsertXMLContent.upsert!(core_file, params[:tei], :tei)
      end

      if params[:support_files]
        UpsertSupportContent.upsert!(core_file, file_hash[:support_files])
      end
    rescue => e 
      ExceptionNotifier.notify_exception(e, :data => { :params => params })
      raise e 
    ensure
      FileUtils.rm params[:tei] if params[:tei] && File.exists?(params[:tei])
      FileUtils.rm params[:support_files] if params[:support_files]
    end
  end


  def update_metadata!
    did = core_file.did
    core_file.depositor = params[:depositor] if params[:depositor].present?
    core_file.drupal_access = params[:access] if params[:access].present?
    core_file.og_reference = params[:collection_dids] if params[:collection_dids].present?

    if params[:collection_dids].present? 
      core_file.save!
      params[:collection_dids].each do |did| 
        if Did.exists_by_did?(did)
          core_file.collections << Collection.find_by_did(did)
        end
      end

      core_file.save!
    end

    # Rewrite the ography relationship that this core file has
    # Currently, every core file can only be one kind of ography
    if params[:file_type].present?
      case params[:file_type]
      when "otherography"
        clear_and_update_ography! :otherography_for=
      when "personography"
        clear_and_update_ography! :personography_for=
      when "orgography"
        clear_and_update_ography! :orgography_for=
      when "bibliography"
        clear_and_update_ography! :bibliography_for=
      when "odd_file"
        clear_and_update_ography! :odd_file_for=
      when "tei_content"
        clear_and_update_ography!
      end
    end

    core_file.save! 
  end

  private 

  def clear_and_update_ography!(ography_assignment = nil)
    core_file.personography_for = []
    core_file.orgography_for = []
    core_file.bibliography_for = []
    core_file.otherography_for = []
    core_file.odd_file_for = []

    if ography_assignment
      core_file.send(ography_assignment, [core_file.project])
    end
  end
end

