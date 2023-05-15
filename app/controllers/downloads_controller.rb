class DownloadsController < ApplicationController
  # include Hydra::Controller::DownloadBehavior

  skip_before_action :authorize_download!
end
