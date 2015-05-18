class CollectionValidator < TapasObjectValidator

  def required_attributes
    case params["action"]
    when "upsert"
      [:did, :project, :title, :depositor, :access]
    end
  end
end
