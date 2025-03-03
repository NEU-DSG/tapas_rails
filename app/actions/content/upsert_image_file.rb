module Content
  class UpsertImageFile
    include Content

    attr_reader :core_file, :filepath

    def initialize(core_file, filepath)
      @core_file = core_file
      @filepath = filepath
    end

    def self.execute(core_file, filepath)
      self.new(core_file, filepath).execute
    end

    def execute
      image_file = core_file.image_file

      unless image_file
       image_file = ::ImageFile.create
       image_file.core_file = core_file
       image_file.save!
      end

      add_unique_file(image_file, :filepath => filepath)

      # Clear and update the CoreFile's image_file list
      core_file.image_files = [image_file.download_path('image_file_1')]
      core_file.save!
    end
  end
end
