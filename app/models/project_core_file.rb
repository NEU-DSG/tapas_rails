# frozen_string_literal: true

class ProjectCoreFile < ActiveRecord::Base
  belongs_to :project
  belongs_to :core_file
end
