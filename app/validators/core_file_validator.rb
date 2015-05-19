class CoreFileValidator < TapasObjectValidator
  def validate_params
    super
    # Validate that params[:mods] is if present a valid mods record
    if params[:mods].present?
      begin
        xml = Nokogiri::XML(params[:mods]) do |config| 
          config.strict.nonet
        end

        xsd_path = Rails.root.join("lib", "assets", "xsd", "mods-3-5.xsd")
        schema = Nokogiri::XML::Schema(File.read(xsd_path))

        xml_errors = schema.validate(xml)

        xml_errors.each do |error| 
          errors << error.message 
        end
      rescue => e 
        errors << "Something went wrong parsing MODS xml.  Original xml was: \n" + 
        "#{params[:mods]}"
        return errors 
      end
    end
    return errors
  end

  def create_attributes
    [:did, :file, :collection_did, :mods, :depositor, :access, :file_type]
  end
end
