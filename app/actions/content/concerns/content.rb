module Content 
  extend ActiveSupport::Concern 

  included do 

    def add_unique_file(content, opts)
      # If we have a blob and a name use those
      if opts[:blob] && opts[:filename]
        new_name = opts[:filename]
        new_content = opts[:blob]
      elsif opts[:filepath]
        new_name = Pathname.new(opts[:filepath]).basename.to_s
        new_content = File.read opts[:filepath]
      else
        raise "Invalid usage"
      end

      current_name = content.filename
      current_content = content.content.content 

      names_match = (new_name == current_name)
      content_matches = (new_content == current_content)

      unless names_match && content_matches 
        content.add_file(new_content, "content", new_name)
      end
      
      content.save!
    end
  end
end
