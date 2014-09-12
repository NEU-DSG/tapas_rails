class CoreFileCreatorService
  include Concerns::TapasObjectCreator

  def create_record 
    # Things to do:
      # 1. Instantiate record with pid assigned
      # 2. Assign metadata from all params [:req_attributes]
      # 3. If a TEI-XML object type is provided, extract the TEI header
      # 4. Assign all file objects to their own content_file objects
      # 5. Return a 201 to some endpoint on the drupal site. 
  end
end