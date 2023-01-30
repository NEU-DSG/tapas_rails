class Community < ActiveRecord::Base
  include Discard::Model

  has_many :collections
  has_many :children, through: :community_collections, source: :collection
  has_many :community_members
  has_many :users, through: :community_members
  has_and_belongs_to_many :communities,
                          join_table: "community_communities",
                          association_foreign_key: "parent_community_id"

  has_many :communities_institutions
  has_many :institutions, through: :communities_institutions

  belongs_to :depositor, class_name: "User"

  has_one_attached :thumbnail

  validates_presence_of :title

  def project_members
    users.where(community_members: { member_type: "member" })
  end

  def project_editors
    users.where(community_members: { member_type: "editor" })
  end

  def project_admins
    users.where(community_members: { member_type: "admin" })
  end

  def as_json
    fname = (thumbnail_1.label == 'File Datastream' ? '' : thumbnail_1.label)
    { :members => project_members,
      :admins => project_admins,
      :editors => project_editors,
      :depositor => depositor,
      :access => drupal_access,
      :thumbnail => fname,
      :title => mods.title.first,
      :description => mods.abstract.first
    }
  end

  def can_read?(user)
    can? :read
  end

  def remove_thumbnail
    self.thumbnails = []
    self.save!
  end

  def member_objects
    member_objects = {}
    if !self.project_admins.blank?
      member_objects[:admins] = []
      self.project_admins.each do |pa|
        if User.exists?(pa)
          member_objects[:admins] << User.find(pa)
        end
      end
    end
    if !self.project_editors.blank?
      member_objects[:editors] = []
      self.project_editors.each do |pe|
        if User.exists?(pe)
          member_objects[:editors] << User.find(pe)
        end
      end
    end
    if !self.project_members.blank?
      member_objects[:members] = []
      self.project_members.each do |pm|
        if User.exists?(pm)
          member_objects[:members] << User.find(pm)
        end
      end
    end
    return member_objects
  end

  def clean_edit_users
    return self.edit_users.keep_if{ |k| k != "" }
  end

end
