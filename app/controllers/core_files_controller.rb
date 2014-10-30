class CoreFilesController < ApplicationController
  include ApiAccessible

  def parse_tei
    response = {}

    str = params[:file].read
    errors = TEIValidator.validate_file(str)
    response[:errors] = errors if errors

    fatal_errors = %W(schematron-fatal schematron-error)

    if response[:errors].any? { |x| fatal_errors.include? x[:class] }
      response[:message] = "Fatal validation errors!" 
      render json: JSON.pretty_generate(response), status: 422 and return
    end

    metadata = TEIMetadataExtractor.extract(str)
    response[:metadata] = metadata

    if response[:errors] && response[:errors].any?
      response[:message] = "Some warnings but OK"
    else
      response[:message] = "OK"
    end

    render json: JSON.pretty_generate(response), status: 200 and return
  end

  private

    def pretty_json(message, status)
      render json: JSON.pretty_generate(message), status: 200
    end
end
