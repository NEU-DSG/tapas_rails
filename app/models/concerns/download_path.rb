module DownloadPath
  def download_path(dsid='content')
    url_helpers = Rails.application.routes.url_helpers
    url_helpers.url_for(:controller => :downloads, 
                        :action => :show, 
                        :id => pid, 
                        :datastream_id => dsid, 
                        :host => Settings['base_url'])
  end
end
