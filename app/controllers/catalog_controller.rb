# -*- encoding : utf-8 -*-
require 'blacklight/catalog'
class CatalogController < ApplicationController
  include Blacklight::Catalog
  include Hydra::Controller::ControllerBehavior
  # include Rails.application.routes.url_helpers
  # These before_filters apply the hydra access controls
  before_filter :enforce_show_permissions, :only=>:show
  # This applies appropriate access controls to all solr queries
  CatalogController.search_params_logic += [:add_access_controls_to_solr_params]
  # This filters out objects that you want to exclude from search results, like FileAssets
  CatalogController.search_params_logic += [:exclude_unwanted_models]

  configure_blacklight do |config|
    config.view.gallery.partials = [:index_header, :index]
    # config.view.masonry.partials = [:index]
    # config.view.slideshow.partials = [:index]

    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)

    config.index.thumbnail_field = 'thumbnail_list_tesim'
    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    config.connection_config = "/config/blacklight.yml"
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
      :qt => 'search',
      :rows => 10
    }

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SearchHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    #config.default_document_solr_params = {
    #  :qt => 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # :fl => '*',
    #  # :rows => 1
    #  # :q => '{!raw f=id v=$id}'
    #}

    # solr field configuration for search results/index views
    config.index.title_field = 'title_info_title_ssi'
    config.index.display_type_field = 'active_fedora_model_ssi'

    # solr field configuration for document/show views
    #config.show.title_field = 'title_display'
    #config.show.display_type_field = 'format'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    # config.add_facet_field 'has_model_ssim', :label => 'Format'
    config.add_facet_field 'type_sim', :label => 'Type'
    config.add_facet_field 'depositor_tesim', :label => 'Depositor'
    config.add_facet_field 'project_ssi', :label => 'Project'
    config.add_facet_field 'collections_ssim', :label => 'Collection'
    # config.add_facet_field 'creator_tesim', :label => 'Creator'
    config.add_facet_field 'display_authors_tesim', :label => 'Authors'
    config.add_facet_field 'display_contributors_tesim', :label => 'Contributors'
    # config.add_facet_field 'collections_ssim'
    # # config.add_facet_field 'pub_date', :label => 'Publication Year', :single => true
    # config.add_facet_field 'subject_topic_facet', :label => 'Topic', :limit => 20
    # config.add_facet_field 'language_facet', :label => 'Language', :limit => true
    # config.add_facet_field 'lc_1letter_facet', :label => 'Call Number'
    # config.add_facet_field 'subject_geo_facet', :label => 'Region'
    # config.add_facet_field 'subject_era_facet', :label => 'Era'
    #
    # config.add_facet_field 'example_pivot_field', :label => 'Pivot Field', :pivot => ['format', 'language_facet']

    # config.add_facet_field 'example_query_facet_field', :label => 'Publish Date', :query => {
    #   :years_5 => { :label => 'within 5 Years', :fq => "pub_date:[#{Time.zone.now.year - 5 } TO *]" },
    #   :years_10 => { :label => 'within 10 Years', :fq => "pub_date:[#{Time.zone.now.year - 10 } TO *]" },
    #   :years_25 => { :label => 'within 25 Years', :fq => "pub_date:[#{Time.zone.now.year - 25 } TO *]" }
    # }


    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'title_info_title_ssi', :label => 'Title'
    # config.add_index_field 'creator_tesim', :label => 'Creator'
    config.add_index_field 'authors_ssim', :label => 'Authors'
    config.add_index_field 'contributors_ssim', :label => 'Contributors'
    # config.add_index_field 'title_vern_display', :label => 'Title'
    # config.add_index_field 'author_display', :label => 'Author'
    # config.add_index_field 'author_vern_display', :label => 'Author'
    config.add_index_field 'active_fedora_model_ssi', :label => 'Type'
    config.add_index_field 'drupal_og_reference_ssim', :label => 'External Links'
    # config.add_index_field 'language_facet', :label => 'Language'
    # config.add_index_field 'published_display', :label => 'Published'
    # config.add_index_field 'published_vern_display', :label => 'Published'
    # config.add_index_field 'lc_callnum_display', :label => 'Call number'

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field 'title_info_title_ssi', :label => 'Title'
    config.add_show_field 'abstract_tesim', :label => 'Description'
    config.add_show_field 'drupal_og_reference_ssim', :label => 'External links'
    config.add_show_field 'project_members_ssim', :label => 'Members'
    config.add_show_field 'authors_ssim', :label => 'Authors'
    config.add_show_field 'contributors_ssim', :label => 'Contributors'
    config.add_show_field 'mass_permissions_ssim', :label => 'Visibility'

    # config.add_show_field 'title_vern_display', :label => 'Title'
    # config.add_show_field 'subtitle_display', :label => 'Subtitle'
    # config.add_show_field 'subtitle_vern_display', :label => 'Subtitle'
    # config.add_show_field 'author_display', :label => 'Author'
    # config.add_show_field 'author_vern_display', :label => 'Author'
    config.add_show_field 'active_fedora_model_ssi', :label => 'Type'

    # config.add_show_field 'url_fulltext_display', :label => 'URL'
    # config.add_show_field 'url_suppl_display', :label => 'More Information'
    # config.add_show_field 'language_facet', :label => 'Language'
    # config.add_show_field 'published_display', :label => 'Published'
    # config.add_show_field 'published_vern_display', :label => 'Published'
    # config.add_show_field 'lc_callnum_display', :label => 'Call number'
    # config.add_show_field 'isbn_t', :label => 'ISBN'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    # config.add_search_field 'all_fields', :label => 'All Fields'
    config.add_search_field('all_fields', label: 'All Fields', include_in_advanced_search: false) do |field|
      # These are generated by the mods datastream
      title = "title_tesim"
      abstract = "abstract_tesim"
      genre = "genre_tesim"
      topic = "subject_topic_tesim"
      authors = "authors_tesim"
      contributors = "contributors_tesim"
      creators = "creator_tesim"
      publisher = "origin_info_publisher_tesim"
      place = "origin_info_place_tesim"
      identifier = "identifier_tesim"
      emp_name = "employee_name_tesim"
      emp_nuid = "employee_nuid_ssim"
      all_text = "all_text_timv"

      field.solr_parameters = {
        qf: "#{title} #{abstract} #{genre} #{topic} #{authors} #{contributors} #{creators} #{publisher} #{place} #{identifier} #{emp_name} #{emp_nuid} #{all_text}",
        pf: "#{title}",
      }
    end


    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.
    #
    # config.add_search_field('title') do |field|
    #   # solr_parameters hash are sent to Solr as ordinary url query params.
    #   field.solr_parameters = { :'spellcheck.dictionary' => 'title' }
    #
    #   # :solr_local_parameters will be sent using Solr LocalParams
    #   # syntax, as eg {! qf=$title_qf }. This is neccesary to use
    #   # Solr parameter de-referencing like $title_qf.
    #   # See: http://wiki.apache.org/solr/LocalParams
    #   field.solr_local_parameters = {
    #     :qf => '$title_qf',
    #     :pf => '$title_pf'
    #   }
    # end

    # config.add_search_field('author') do |field|
    #   field.solr_parameters = { :'spellcheck.dictionary' => 'author' }
    #   field.solr_local_parameters = {
    #     :qf => '$author_qf',
    #     :pf => '$author_pf'
    #   }
    # end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    # config.add_search_field('subject') do |field|
    #   field.solr_parameters = { :'spellcheck.dictionary' => 'subject' }
    #   field.qt = 'search'
    #   field.solr_local_parameters = {
    #     :qf => '$subject_qf',
    #     :pf => '$subject_pf'
    #   }
    # end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc', :label => 'relevance'
    config.add_sort_field 'title_info_title_ssi asc, score desc', :label => 'title a-z'
    config.add_sort_field 'title_info_title_ssi desc, score desc', :label => 'title z-a'
    config.add_sort_field 'system_create_dtsi desc', :label => 'most recently added'
    config.add_sort_field 'system_modified_dtsi desc', :label => 'most recently updated'
    # config.add_sort_field 'score desc, pub_date_sort desc, title_sort asc', :label => 'relevance'
    # config.add_sort_field 'pub_date_sort desc, title_sort asc', :label => 'year'
    # config.add_sort_field 'author_sort asc, title_sort asc', :label => 'author'
    # config.add_sort_field 'title_sort asc, pub_date_sort desc', :label => 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    config.index.document_actions.delete(:bookmark)
    config.show.document_actions.delete(:citation)
    config.show.document_actions.delete(:bookmark)
    config.show.document_actions.delete(:email)
    config.show.document_actions.delete(:sms)
  end

  def search_action_url(options = {})
    # Rails 4.2 deprecated url helpers accepting string keys for 'controller' or 'action'
    catalog_index_path(options.except(:controller, :action))
  end

  def exclude_unwanted_models(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    # solr_parameters[:fq] << "#{Solrizer.solr_name("has_model", :symbol)}:\"info:fedora/afmodel:CoreFile\""
    solr_parameters[:fq] << "-#{Solrizer.solr_name("is_supplemental_material_for", :symbol)}:[* TO *]"
  end

  def browse
    logger.info ENV.to_yaml
    render 'browse'
  end

end
