class CommunityValidator < TapasObjectValidator
  def required_attributes
    case params[:action]
    when "upsert" 
      [:nid, :title, :members, :depositor, :access]
    end
  end
end
