class Page < ActiveRecord::Base
  extend FriendlyId
  include SolrHelpers


  attr_accessible :title, :content, :slug, :publish, :submenu if Rails::VERSION::MAJOR < 4
  validates_presence_of :title, :content, :slug
  validates :slug, uniqueness: { case_sensitive: false }
  friendly_id :slug, use: :slugged

  after_save :index_record
  # deletes the record from the solr index
  before_destroy :delete_record

  def to_solr
    obj =
    {'id' => "#{self.class.to_s}_#{id}",
     'title_info_title_ssi' => self.title,
     'all_text_timv' => self.content,
     'type_sim' => 'Page',
     'active_fedora_model_ssi' => 'Page',
   }
   if self.publish == "true"
     obj['read_access_group_ssim'] = ['public']
   end
   return obj
  end

end
