class CommunityValidator < TapasObjectValidator
  def create_attributes
    [:did, :members, :depositor, :access, :title, :description]
  end
end
