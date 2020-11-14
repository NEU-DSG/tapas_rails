class NewsItem < ActiveRecord::Base
  extend FriendlyId

  attr_accessible :title, :content, :slug, :publish, :author, :tags if Rails::VERSION::MAJOR < 4
  validates_presence_of :title, :content, :slug
  validates :slug, uniqueness: { case_sensitive: false }
  friendly_id :slug, use: :slugged

  after_save :index_record
  before_destroy :remove_from_index

  def to_solr
    obj =
    {'id' => self.id,
     'title_info_title_ssi' => self.title,
     'all_text_timv' => self.content,
     'type_sim' => 'News Item',
     'active_fedora_model_ssi' => 'NewsItem',
     'creator_tesim' => self.author,
     'edit_access_person_ssim' => self.author
   }
   if self.publish == "true"
     obj['read_access_group_ssim'] = ['public']
   end
   return obj
  end

end
