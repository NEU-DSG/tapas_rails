class CollectionValidator < TapasObjectValidator

  def required_attributes
    case params["action"]
    when "create"
      [:nid, :project, :title, :depositor]
    end
  end
end
