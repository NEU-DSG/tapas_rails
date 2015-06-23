require "zip"

class UpsertCoreFile
  include Concerns::Upserter
  attr_accessor :core_file # Saves the core file this upserter is handling
  attr_accessor :file_hash

  def initialize(params)
    @params = params
  end

  def upsert
    begin 
      self.file_hash = ExtractFiles.extract!(params[:files])

      if Did.exists_by_did?(params[:did])
        self.core_file = CoreFile.find_by_did(params[:did])
      else
        self.core_file = CoreFile.create(:did => params[:did])
        ensure_complete_upload!
      end

      update_metadata!

      if file_hash[:teibp]
        UpsertHTMLContent.upsert!(core_file, file_hash[:teibp], :teibp)
      end
      
      if file_hash[:tapas_generic]
        UpsertHTMLContent.upsert!(core_file, file_hash[:tapas_generic], :tapas_generic)
      end

      if file_hash[:tei]
        UpsertXMLContent.upsert!(core_file, file_hash[:tei], :tei)
      end

      if file_hash[:tfc]
        UpsertXMLContent.upsert!(core_file, file_hash[:tfc], :tfc)
      end

      if file_hash[:support_files]
        UpsertSupportContent.upsert!(core_file, file_hash[:support_files])
      end
    rescue => e 
      ExceptionNotifier.notify_exception(e, :data => { :params => params })
      raise e 
    ensure
      FileUtils.rm_rf file_hash[:directory]
    end
  end


  def update_metadata!
    did = core_file.did
    core_file.depositor = params[:depositor] if params[:depositor].present?
    core_file.drupal_access = params[:access] if params[:access].present?
    core_file.og_reference = params[:collection_dids] if params[:collection_dids].present?

    # Make sure to rewrite the did/pid after updating MODS.
    if file_hash[:mods]
      core_file.mods.content = File.read(file_hash[:mods])
      core_file.did = did 
      core_file.mods.identifier = core_file.pid 
    end

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

  # If we have a new Core File being created, raise an error unless all needed 
  # files are present
  def ensure_complete_upload! 
    mods = file_hash[:mods] 
    tei = file_hash[:tei]
    tfc = file_hash[:tfc]
    teibp = file_hash[:teibp]
    tapas_generic = file_hash[:tapas_generic]

    unless mods && tei && tfc && teibp && tapas_generic
      raise "Could not create a new Core File using the zipped content!" \
        " Mods file found at #{mods || 'NOT FOUND'}," \
        " TEI file found at #{tei || 'NOT FOUND'}," \
        " TFC file found at #{tfc || 'NOT FOUND'}"
    end 
  end

  def clear_and_update_ography!(ography_assignment = nil)
    core_file.personography_for = []
    core_file.orgography_for = []
    core_file.bibliography_for = []
    core_file.otherography_for = []
    core_file.odd_file_for = []

    if ography_assignment
      core_file.send(ography_assignment, [*core_file.collections])
    end
  end
end

