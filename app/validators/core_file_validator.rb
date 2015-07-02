class CoreFileValidator < TapasObjectValidator
  def create_attributes
    [:did, :collection_dids, :depositor, :access, :file_type, :tei]
  end
end
