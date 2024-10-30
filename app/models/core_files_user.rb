 # frozen_string_literal: true

class CoreFilesUser < ActiveRecord::Base
  validates :user, uniqueness: { scope: :core_file }
end
