class CoreFilesUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :core_file

  validates :user, uniqueness: { scope: :core_file }
end
