class DownloadsController < ApplicationController
  include Hydra::Controller::DownloadBehavior

  skip_before_filter :authorize_download!
end
