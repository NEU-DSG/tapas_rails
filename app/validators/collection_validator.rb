class CollectionValidator < TapasObjectValidator

  def required_attributes
    case params["action"]
    when "upsert"
      [:nid, :project, :title, :depositor, :access]
    end
  end
end
