class NewsItem < ApplicationRecord
  extend FriendlyId
  include SolrHelpers


  attr_accessible :title, :content, :slug, :publish, :author, :tags if Rails::VERSION::MAJOR < 4
  validates_presence_of :title, :content, :slug
  validates :slug, uniqueness: { case_sensitive: false }
  friendly_id :slug, use: :slugged

  after_save :index_record

  def to_solr
    obj =
    {'id' => "#{self.class.to_s}_#{id}",
     'title_info_title_ssi' => self.title,
     'all_text_timv' => self.content,
     'type_sim' => 'News Item',
     'active_record_model_ssi' => 'NewsItem',
     'creator_tesim' => self.author,
     # TODO: review fields included in solr hash objects generated from class methods to determine if they're still useful
     'edit_access_person_ssim' => self.author
   }
   if self.publish == "true"
     obj['read_access_group_ssim'] = ['public']
   end
   return obj
  end

end
