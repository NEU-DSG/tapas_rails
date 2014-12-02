class CommunityValidator < TapasObjectValidator
  def required_attributes
    case params[:action]
    when "create"
      [:nid, :title, :members, :depositor] 
    when "nid_update"
      []
    end
  end
end
