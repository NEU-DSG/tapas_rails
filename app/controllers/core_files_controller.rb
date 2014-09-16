class CoreFilesController < ApplicationController
  include ApiAccessible

  def parse_tei
    errors = TEIValidator.validate_file(params[:file])

    fatal_errors = %W(schematron-fatal schematron-error)

    if errors.any? { |x| fatal_errors.include? x[:class] }
      json = { message: "Fatal validation errors", errors: errors }
      render json: JSON.pretty_generate(json), status: 422 and return 
    end

    metadata = TEIMetadataExtractor.extract(params[:file])

    if errors.any?
      json = { 
              message: "Some warnings raised",
              errors:  errors,
              metadata: metadata
             }
      render json: JSON.pretty_generate(json), status: 200 and return 
    else
      json = { message: "OK", metadata: metadata }
      render json: JSON.pretty_generate(json), status: 200 and return 
    end
  end
end
