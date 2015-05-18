class CommunityValidator < TapasObjectValidator
  def required_attributes
    case params[:action]
    when "upsert" 
      [:did, :title, :members, :depositor, :access]
    end
  end
end
