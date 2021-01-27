class Community < ActiveRecord::Base
  include Discard::Model

  has_many :collections
  has_many :children, through: :community_collections, source: :collection
  has_many :community_members
  has_many :users, through: :community_members
  has_and_belongs_to_many :communities,
                          join_table: 'community_communities',
                          association_foreign_key: 'parent_community_id'

  has_many :communities_institutions
  has_many :institutions, through: :communities_institutions

  belongs_to :depositor, class_name: 'User'

  has_one_attached :thumbnail

  validates_presence_of :title

  after_create :add_depositor_to_admins

  def project_members
    users.where(community_members: { member_type: 'member' })
  end

  def project_editors
    users.where(community_members: { member_type: 'editor' })
  end

  def project_admins
    users.where(community_members: { member_type: 'admin' })
  end

  def can_read?
    can? :read
  end

  # alias for ActiveStorage attach
  def add_thumbnail(io: nil, filename: nil)
    return if io.nil? || filename.nil?

    thumbnail.attach(io: io, filename: filename)
  end

  def remove_thumbnail
    thumbnail.purge
  end

  def clean_edit_users
    edit_users.keep_if { |k| k != '' }
  end

  def add_depositor_to_admins
    if user = users.find_by(id: depositor.id)
      CommunityMember.find_by(user: user, communitY_id: id).update(member_type: 'admin')
    else
      CommunityMember.create!(community_id: id, user_id: depositor.id, member_type: 'admin')
    end
  end
end
