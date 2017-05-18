class Page < ActiveRecord::Base
  extend FriendlyId
  include Bootsy::Container
  include SolrHelpers


  attr_accessible :title, :content, :slug if Rails::VERSION::MAJOR < 4
  validates_presence_of :title, :content, :slug
  validates :slug, uniqueness: { case_sensitive: false }
  friendly_id :slug, use: :slugged

  after_save :index_record
  before_destroy :remove_from_index

  def to_solr
    # *_texts here is a dynamic field type specified in solrconfig.xml
    {'id' => self.id,
     'title_info_title_ssi' => self.title,
     'all_text_timv' => self.content
   }
  end

end
