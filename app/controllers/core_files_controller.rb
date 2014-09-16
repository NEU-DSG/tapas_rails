class CoreFilesController < ApplicationController
  include ApiAccessible

  def parse_tei
    errors = TEIValidator.validate_file(params[:file])

    fatal_errors = %W(schematron-fatal schematron-error)

    if errors.any? { |x| fatal_errors.include? x[:class] }
      json = { message: "Fatal validation errors", errors: errors }
      render json: JSON.pretty_generate(json), status: 422 and return 
    end
    #TODO Handle metadata extraction
  end
end
