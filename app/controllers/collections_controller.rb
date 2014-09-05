class CollectionsController < ApplicationController
  include ApiAccessible

  def create
    render nothing: true, status: 200
  end
end
