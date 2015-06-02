class CoreFileValidator < TapasObjectValidator
  def create_attributes
    [:did, :collection_did, :depositor, :access, :file_type, :files]
  end
end
