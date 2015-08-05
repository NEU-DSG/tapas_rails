require "zip" 

# A class that handles taking apart the zip files used to ingest content
# associated with a TEI file upload.  
class ExtractFiles
  attr_accessor :tmp_dir
  attr_reader :zip_path 

  def initialize(zip_path)
    @zip_path = zip_path 
  end

  def self.execute(zip_path)
    ExtractFiles.new(zip_path).execute
  end

  # Returns a hash with each of the following keys set to a file path assuming
  # that some content could be found: 
  # - thumbnail: The image thumbnail associated with this TEIFile.
  # Also returns the following key set to an array of files paths: 
  # - page_images: All page images associated with this TEI File.  May be 
  # jpegs or pngs.
  def execute
    response = {} 
    @tmp_dir = "#{Rails.root}/tmp/extracted_files/#{SecureRandom.hex}"
    FileUtils.mkdir_p tmp_dir

    response[:directory] = @tmp_dir

    # Ensure page_images is always initialized to an empty array
    response[:page_images] = []

    Zip::File.open(zip_path) do |zip|
      zip.each do |entry| 
        name = entry.name
        if name.split('/').second == 'thumbnail' && real_file?(entry)
          response[:thumbnail] = write_to_file entry
        elsif name.split("/").second == "page_images" && real_file?(entry)
          response[:page_images] << write_to_file(entry)
        end
      end
    end
    response
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
