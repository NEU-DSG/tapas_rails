class CommunitiesController < ApplicationController
  # Don't run CSRF checks against JSON actions.
  skip_before_action :verify_authenticity_token
  # Authenticate against API keys for JSON create requests
  # before_action :token_auth, only: ["create"]


  def index

  end

  def new

  end

  def create
    render text: "all good" 
    return
  end

  def show

  end

  def edit 

  end

  def update 

  end

  def delete 

  end

  private 

    def token_auth
      authenticate_or_request_with_http_token do |token, options| 
        u = User.find_by(token: token)
        unless u.can? :edit, @community
          render_json_404 
        end
      end
    end
end
