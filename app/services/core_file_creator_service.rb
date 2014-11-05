class CoreFileCreatorService
  include Concerns::TapasObjectCreator

  def create_record 
    # Things to do:
      # 1. Instantiate record with pid assigned
      # 2. Assign metadata from all params
      # 3. If a TEI-XML object type is provided, extract the TEI header
      # 4. Assign all file objects to their own content_file objects
      # 5. Return a 201 to some endpoint on the drupal site. 

    core     = nil 
    tei_file = nil

    # 1. Instantiate a core record 
    core = CoreFile.new

    # 2. Assign metadata from all params
    core.depositor  = params[:depositor]
    # TODO: How do collections work now?

    # Take params[:file] (always assumed to be a string file path as 
    # this makes enqueing this in a job possible), extract it to its 
    # own TEIFile object, and kick off inline derivation creation
    tei_file = TEIFile.new(depositor: params[:depositor])
    file_str = File.read(params[:file])
    tei_file.content = file_str
    FileUtils.rm(params[:file])
  end
end