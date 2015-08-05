module Content 

  def add_unique_file(content, opts)
    # If we have a blob and a name use those
    if opts[:blob] && opts[:filename]
      new_name = opts[:filename]
      new_content = opts[:blob]
    elsif opts[:filepath]
      new_name = Pathname.new(opts[:filepath]).basename.to_s
      new_content = File.open(opts[:filepath], 'rb') { |io| io.read }
    else
      raise "Invalid usage"
    end

    current_name = content.filename

    if content.instance_of? ::ImageThumbnailFile
      current_content = content.thumbnail_1.content
    else
      current_content = content.content.content
    end

    names_match = (new_name == current_name)
    content_matches = (new_content == current_content)

    unless names_match && content_matches 
      ds = content.instance_of?(::ImageThumbnailFile)?'thumbnail_1':'content'
      content.add_file(new_content, ds, new_name)
    end

    content.save!
  end
end
