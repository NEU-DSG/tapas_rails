module ControllerHelper
  # Checks if the current user can read the fedora record
  # returned by a typical resource request.
  def can_read?
    logger.error "in can_read?"
    begin
      record = SolrDocument.new(ActiveFedora::SolrService.query("id:\"#{params[:id]}\"").first)
    rescue NoMethodError
      render_404(ActiveFedora::ObjectNotFoundError.new, request.fullpath) and return
    end

    if current_user.nil?
      record.public? ? true : render_403
    elsif current_user.can? :read, record
      return true
    else
      render_403
    end
  end
end
