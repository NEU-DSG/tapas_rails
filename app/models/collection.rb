class Collection < ActiveRecord::Base
  include Discard::Model

  belongs_to :community
  belongs_to :depositor, class_name: 'User'
  # TODO: Follow up with Candace to double check about the Collections <> Collections relationships
  # has_and_belongs_to_many :collections,
  #                         join_table: "collection_collections",
  #                         association_foreign_key: "parent_collection_id"

  has_and_belongs_to_many :core_files

  has_many_attached :thumbnails

  validates :depositor, :description, :title, presence: true

  before_save :update_core_file_publicity

  def project
    # TODO: (charles) This makes it look like a collection belongs_to a single community,
    # but elsewhere it seems like collections can be shared. Which way should we go?
    unless community_id.blank?
      return Community.find(community_id) if Community.exists?(community_id)
    end

    nil
  end

  def remove_thumbnail
    update(thumbnails: [])
  end

  def update_core_file_publicity
    return if is_public.nil?
    return if is_public == is_public_was
    puts id, is_public
    if is_public
      core_files.update_all(is_public: true)
    else
      # FIXME: (charles) This is a lot of n+1 queries to run,
      # but I'm hitting a wall on a better way to do it
      core_files.each do |cf|
        publicity = cf.collections.where.not(id: id).pluck(:is_public)
        cf.update(is_public: false) unless publicity.any? { |p| p }
      end
    end
  end
end
