class CoreFileValidator < TapasObjectValidator
  def required_attributes
    case params[:action]
    when "upsert" 
      [:depositor, :did, :collection, :access]
    when "parse_tei"
      [:file]
    end 
  end
end
