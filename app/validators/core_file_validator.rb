class CoreFileValidator < TapasObjectValidator
  def required_attributes
    case params[:action]
    when "upsert" 
      [:depositor, :nid, :collection, :file, :access]
    when "parse_tei"
      [:file]
    end 
  end
end
