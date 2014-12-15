class CoreFilesController < ApplicationController
  include ApiAccessible

  # No strict guarantee that parse_tei will always run before 
  # the create action, so just always execute validations
  before_action :validate_tei_content, :only => %i(parse_tei)

  def upsert
    # If params[:file] is set to anything, we assume 
    # we need to perform a file content update - extract 
    # filepath and filename
    if params[:file].present?
      params[:filename] = params[:file].original_filename 
      
      fpath = params[:file].path
      npath = Rails.root.join("tmp", params[:filename])
      FileUtils.mv(fpath, npath)
      params[:filepath] = npath.to_s 

      # @TODO: We set this to a blank string because the actual File stored here
      # won't serialize very well.  There's a better way to handle this.
      params[:file] = "" 
    end

    TapasRails::Application::Queue.push TapasObjectUpsertJob.new params 
    @response[:message] = "CoreFile create/update in progress" 
    pretty_json(202) and return 
  end

  def parse_tei
    metadata = TEIMetadataExtractor.extract(@file)
    @response[:metadata] = metadata

    if @response[:errors] && @response[:errors].any?
      @response[:message] = "Some warnings but OK"
    else
      @response[:message] = "OK"
    end

    pretty_json(200) and return
  end

  private

   def move_and_pathify_file
     fpath = params[:file].path
     fname = Pathname.new(fpath).basename.to_s
     npath = Rails.root.join("tmp", fname)
     FileUtils.mv(fpath, npath)
     params[:file] = npath.to_s
   end

   def validate_tei_content
      @file     = params[:file].read

      errors = TEIValidator.validate_file(@file)
      @response[:errors] = errors if errors 

      fatal_errors = %W(schematron-fatal schematron-error)
      if @response[:errors] && @response[:errors].any? { |x| fatal_errors.include? x[:class] } 
        @response[:message] = "Fatal validation errors!"
        pretty_json(422) and return 
      end
    end
end
