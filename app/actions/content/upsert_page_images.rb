module Content
  class UpsertPageImages
    attr_reader :core_file, :new_files
    include Content

    def initialize(core_file, new_files)
      @core_file = core_file
      @new_files = new_files
    end

    def self.execute(core_file, new_files)
      self.new(core_file, new_files).execute
    end

    def execute
      ZipContentValidator.support_files new_files

      # Purge all preexisting page image objects
      core_file.page_images.each { |x| x.delete }

      new_files.each do |page_image|
        imf = ImageMasterFile.create
        fname = Pathname.new(page_image).basename.to_s
        # imf.core_file = core_file
        imf.page_image_for << core_file
        imf.add_file(IO.binread(page_image), 'content', fname)
        imf.save!
      end
    end
  end
end
