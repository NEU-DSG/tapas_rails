module Content
  class UpsertThumbnail
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
      thumbnail = core_file.thumbnail

      unless thumbnail
       thumbnail = ::ImageThumbnailFile.create
       thumbnail.core_file = core_file
       thumbnail.save!
      end

      add_unique_file(thumbnail, :filepath => filepath)

      # Clear and update the CoreFile's thumbnail list
      core_file.thumbnail_list = [thumbnail.download_path('thumbnail_1')]
      core_file.save!
    end
  end
end
