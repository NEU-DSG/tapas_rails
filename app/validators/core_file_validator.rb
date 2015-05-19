class CoreFileValidator < TapasObjectValidator
  def create_attributes
    [:did, :file, :collection_did, :mods, :depositor, :access, :file_type]
  end
end
