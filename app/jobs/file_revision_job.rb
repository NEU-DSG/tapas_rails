class FileRevisionJob
  attr_reader :nid, :filepath, :filename

  def initialize(nid, filepath, filename)
    @nid = nid
    @filepath = filepath
    @filename = filename
  end

  def run 
    begin 
      core = CoreFile.find_by_nid(nid)
      core = CoreFile.find core.id 

      tei_file = core.canonical_object(:return_as => :models)
      tei_file.add_file(File.read(filepath), "content", filename)
      tei_file.save!
    rescue => e
      data = { nid: nid, filepath: filepath, filename: filename }
      ExceptionNotifier.notify_exception(e, data: data)
      raise e
    ensure
      FileUtils.rm(filepath)
    end
  end
end
