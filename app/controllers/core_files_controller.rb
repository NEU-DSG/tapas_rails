class CoreFilesController < ApplicationController
  include ApiAccessible

  # No strict guarantee that parse_tei will always run before 
  # the create action, so just always execute validations
  before_action :validate_tei_content

  def create
    params.except!(:email, :token)

    # Rewrite the file param to be a path string
    fpath = params[:file].path
    fname = Pathname.new(fpath).basename.to_s
    npath = Rails.root.join("tmp", fname)
    FileUtils.mv(fpath, npath)
    params[:file] = npath.to_s

    job = TapasObjectCreationJob.new(params, "CoreFile")
    TapasRails::Application::Queue.push(job)
    @response[:message] = "Your files are processing." 
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

    def pretty_json(status)
      render json: JSON.pretty_generate(@response), status: status
    end

    def validate_tei_content
      @response = {}
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
