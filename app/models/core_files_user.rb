class CoreFilesUser < ActiveRecord::Base
  belongs_to :user, inverse_of: :core_files_users
  belongs_to :core_file, inverse_of: :core_files_users

  validates :user, uniqueness: { scope: :core_file }
end
