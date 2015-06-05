require "zip" 

# A class that handles taking apart the zip files used to ingest content
# associated with a TEI file upload.  
class ExtractFiles
  attr_accessor :tmp_dir
  attr_reader :zip_path 

  def initialize(zip_path)
    @zip_path = zip_path 
  end

  def self.extract!(zip_path)
    ExtractFiles.new(zip_path).extract!
  end

  # Returns a hash with each of the following keys set to a file path assuming
  # that some content could be found: 
  # - mods: The MODS XML metadata record for this upload 
  # - tei: The TEI XML content for this upload 
  # - tfc: The Tapas Friendly Copy of the TEI document in this upload 
  # Also returns the following key set to an array of files paths: 
  # - support_files: All support files (at this point, this basically means 
  # images) associated with this upload
  def extract!
    begin 
      response = {} 
      @tmp_dir = "#{Rails.root}/tmp/extracted_files/#{SecureRandom.hex}"
      FileUtils.mkdir_p tmp_dir

      response[:directory] = @tmp_dir

      # Ensure support_files is always initialized to an empty array
      response[:support_files] = []

      Zip::File.open(zip_path) do |zip|
        zip.each do |entry| 
          name = entry.name
          if Pathname.new(name).basename.to_s == "mods.xml"
            response[:mods] = write_to_file entry 
          elsif Pathname.new(name).basename.to_s == "tfc.xml" 
            response[:tfc] = write_to_file entry 
          elsif name.split("/").second == "tei" && real_file?(entry)
            response[:tei] = write_to_file entry
          elsif name.split("/").second == "teibp" && real_file?(entry)
            response[:teibp] = write_to_file entry 
          elsif name.split("/").second == "tapas_generic" && real_file?(entry)
            response[:tapas_generic] = write_to_file entry
          elsif name.split("/").second == "support_files" && real_file?(entry)
            response[:support_files] << write_to_file(entry)
          end
        end
      end
      response
    ensure
      FileUtils.rm zip_path if File.exists? zip_path
    end
  end

  private 
  def real_file?(entry)
    entry.file? && entry.name.split('/').last.first != '.' 
  end

  def write_to_file(entry) 
    return nil unless entry 
    fname = Pathname.new(entry.name).basename.to_s
    path  = Pathname.new(tmp_dir).join(fname).to_s
    entry.extract(path)
    path
  end
end
