class UpsertSupportFiles 
  attr_reader :core_file, :new_files
  include Content

  def initialize(core_file, new_files)
    @core_file = core_file
    @new_files = new_files 
  end

  def self.upsert!(core_file, new_files) 
    self.new(core_file, new_files).upsert!
  end

  def upsert!
    begin
      ZipContentValidator.support_files new_files

      # Purge all preexisting page image objects 
      core_file.page_images.each { |x| x.delete } 

      new_files.each do |page_image| 
        imf = ImageMasterFile.create
        fname = Pathname.new(page_image).basename.to_s 
        imf.core_file = core_file 
        imf.page_image_for << core_file 
        imf.add_file(File.open(page_image), 'content', fname)
        imf.save!
      end
    ensure
      new_files.each { |f| FileUtils.rm_f f } 
    end
  end
end
