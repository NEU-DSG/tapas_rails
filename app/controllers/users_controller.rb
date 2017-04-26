require 'blacklight/catalog'
class UsersController < ApplicationController
  include Blacklight::Catalog
  include Blacklight::Controller

  before_filter :prepend_view_paths

  self.copy_blacklight_config_from(CatalogController)

  def prepend_view_paths
    prepend_view_path "app/views/catalog/"
  end

  def my_tapas
    @page_title = "My TAPAS"
    @user = current_user
    self.search_params_logic += [:my_communities_filter]
    (@projects, @document_list) = search_results(params, search_params_logic)
    render 'my_tapas'
  end

  def my_communities_filter(solr_parameters, user_parameters)
    model_type = RSolr.solr_escape "info:fedora/afmodel:Community"
    query = "has_model_ssim:\"#{model_type}\" && project_members_ssim:\"#{@user.id}\""
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << query
  end

  def search_action_url(options = {})
    # Rails 4.2 deprecated url helpers accepting string keys for 'controller' or 'action'
    catalog_index_path(options.except(:controller, :action))
  end

end
