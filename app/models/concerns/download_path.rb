module DownloadPath
  def download_path(dsid='content')
    url_helpers = Rails.application.routes.url_helpers
    url_helpers.url_for(:controller => :downloads, 
                        :action => :show, 
                        :id => id,
                        # TODO: determine what should replace datastream_id
                        # :datastream_id => dsid,
                        :host => Settings['base_url'])
  end
end
