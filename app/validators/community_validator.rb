class CommunityValidator < TapasObjectValidator
  def required_attributes
    case params[:action]
    when "create"
      [:nid, :title, :members] 
    when "update"
      #TODO
    end
  end
end
