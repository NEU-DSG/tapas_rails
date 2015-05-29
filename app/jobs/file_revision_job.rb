class FileRevisionJob
  attr_reader :did, :filepath, :filename

  def initialize(did, filepath, filename)
    @did = did
    @filepath = filepath
    @filename = filename
  end

  def run 
    begin 
      core = CoreFile.find_by_did(did)
      core = CoreFile.find core.id 

      tei_file = core.canonical_object(:model)
      tei_file.add_file(File.read(filepath), "content", filename)
      tei_file.save!
    rescue => e
      data = { did: did, filepath: filepath, filename: filename }
      ExceptionNotifier.notify_exception(e, data: data)
      raise e
    ensure
      FileUtils.rm(filepath)
    end
  end
end
