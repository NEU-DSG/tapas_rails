module ControllerHelper
  # Checks if the current user can read the record
  # returned by a typical resource request.
  def can_read?
    begin
      record = SolrDocument.new(SolrService.query("id:\"#{params[:id]}\"").first)
    rescue NoMethodError
      render_404(Exception.new, request.fullpath) and return
    end

    if current_user.nil?
      record.public? ? true : render_403
    elsif current_user.can? :read, record
      return true
    else
      render_403
    end
  end

  def can_edit?
    begin
      record = SolrDocument.new(SolrService.query("id:\"#{params[:id]}\"").first)
    rescue NoMethodError
      render_404(Exception.new, request.fullpath) and return
    end

    if current_user.nil?
      render_403
    elsif current_user.can? :edit, record
      return true
    else
      render_403
    end
  end
end
