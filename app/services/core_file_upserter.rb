require "zip"

class CoreFileUpserter
  include Concerns::Upserter
  attr_accessor :core_file # Saves the core file this upserter is handling
  attr_accessor :mods_path
  attr_accessor :tei_path
  attr_accessor :tfc_path
  attr_accessor :teibp_path 
  attr_accessor :tapas_generic_path
  attr_accessor :support_file_paths

  def initialize(params)
    @params = params
    if params[:files] 
      all_files = ExtractFiles.extract!(params[:files])
      @mods_path = all_files[:mods] 
      @tei_path = all_files[:tei]
      @tfc_path = all_files[:tfc]
      @support_file_paths = all_files[:support_files]
    end
  end

  def upsert 
    begin 
      ZipContentValidator.mods(mods_path) if mods_path
      ZipContentValidator.tei(tei_path) if tei_path
      ZipContentValidator.tfc(tfc_path) if tfc_path 
      ZipContentValidator.html(teibp_path) if teibp_path
      ZipContentValidator.html(tapas_generic_path) if tapas_generic_path

      if support_file_paths.any?
        ZipContentValidator.support_files(support_file_paths)
      end

      if Did.exists_by_did?(params[:did])
        self.core_file = CoreFile.find_by_did(params[:did])
      else
        self.core_file = CoreFile.create(:did => params[:did])
        ensure_complete_upload!
      end

      update_metadata!
      update_html_file!("teibp") 
      update_html_file!("tapas_generic")
      update_xml_file!(tei_path, :tei) if tei_path
      update_xml_file!(tfc_path, :tfc) if tfc_path
      update_support_files! if support_file_paths
    rescue => e 
      ExceptionNotifier.notify_exception(e, :data => { :params => params })
      raise e 
    ensure
      FileUtils.rm mods_path if mods_path
      FileUtils.rm tei_path if tei_path
      FileUtils.rm tfc_path if tfc_path
      FileUtils.rm teibp_path if teibp_path
      FileUtils.rm tapas_generic_path if tapas_generic_path
      support_file_paths.each { |sf| FileUtils.rm sf }
    end
  end

  def update_html_file!(html_type)
    if html_type == "teibp" 
      return nil unless teibp_path
      path = teibp_path
    elsif html_type == "tapas_generic" 
      return nil unless tapas_generic_path 
      path = tapas_generic_path
    else
      raise "Invalid HTML file type specified" 
    end

    if core_file.send(html_type.to_sym, :raw)
      html = core_file.send(html.to_sym)
    else
      html = HTMLFile.create
      html.core_file = core_file
      html.html_for << core_file 
      html.html_type = html_type 
    end

    add_unique_file!(html, path)
  end

  def update_metadata!
    did = core_file.did
    core_file.depositor = params[:depositor] if params[:depositor].present?
    core_file.drupal_access = params[:access] if params[:access].present?
    core_file.og_reference = params[:collection_did] if params[:collection_did].present?

    # Make sure to rewrite the did/pid after updating MODS.
    if mods_path
      core_file.mods.content = File.read(mods_path)
      core_file.did = did 
      core_file.mods.identifier = core_file.pid 
    end

    if params[:collection_did].present?
      core_file.save! unless core_file.persisted?

      if Did.exists_by_did? params[:collection_did]
        core_file.collection = Collection.find_by_did params[:collection_did]
      else
        core_file.collection = Collection.phantom_collection
      end
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

  def update_xml_file!(filepath, file_type)
    if file_type == :tei
      content = core_file.canonical_object
    elsif file_type == :tfc 
      content = core_file.tfc.first 
    else
      raise "Invalid XML file type passed to update_xml_file!" 
    end

    unless content 
      content = TEIFile.new 
      if file_type == :tei 
        content.save!
        content.canonize
      elsif file_type == :tfc 
        content.save! 
        content.tfc_for << core_file 
      end

      content.core_file = core_file 
    end

    add_unique_file!(content, filepath)
  end

  def update_support_files!
    # First, remove all current support files
    core_file.content_objects.each do |content|
      unless content.instance_of? TEIFile
        content.destroy
      end
    end

    support_file_paths.each do |support_file| 
      imf = ImageMasterFile.new(:depositor => core_file.depositor)
      fname = Pathname.new(support_file).basename.to_s
      imf.save!
      imf.core_file = core_file 
      imf.add_file(File.open(support_file), "content", fname)
      imf.save!
    end
  end

  private 

  def add_unique_file!(content_object, filepath)
    new_filename = Pathname.new(filepath).basename.to_s 
    new_filecontent = File.read filepath 

    current_filename = content_object.content.label 
    current_filecontent = content_object.content.content 

    fnames_match = (current_filename == new_filename)
    fcontent_matches = (new_filecontent == current_filecontent) 

    unless fnames_match && fcontent_matches 
      content_object.add_file(new_filecontent, "content", new_filename)
    end

    content_object.save!
  end

  # If we have a new Core File being created, raise an error unless all needed 
  # files are present
  def ensure_complete_upload! 
    unless mods_path && tei_path && tfc_path
      raise "Could not create a new Core File using the zipped content!" \
        " Mods file found at #{mods_path || 'NOT FOUND'}," \
        " TEI file found at #{tei_path || 'NOT FOUND'}," \
        " TFC file found at #{tfc_path || 'NOT FOUND'}"
    end 
  end

  def clear_and_update_ography!(ography_assignment = nil)
    core_file.personography_for = []
    core_file.orgography_for = []
    core_file.bibliography_for = []
    core_file.otherography_for = []
    core_file.odd_file_for = []

    if ography_assignment
      core_file.send(ography_assignment, [core_file.collection])
    end
  end
end

