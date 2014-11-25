class CoreFileValidator < TapasObjectValidator
  def required_attributes
    case params[:action]
    when "create"
      [:depositor, :nid, :collection, :file]
    when "update"
      []
    end
  end
end
