module Content 
  extend ActiveSupport::Concern 

  included do 

    def add_unique_file(content, new_content_path)
      new_name = Pathname.new(new_content_path).basename.to_s
      new_content = File.read new_content_path

      current_name = content.content.label 
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
