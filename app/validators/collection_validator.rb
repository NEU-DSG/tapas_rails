class CollectionValidator < TapasObjectValidator
  def create_attributes
    [:did, :project_did, :title, :description, :depositor, :access]
  end
end
