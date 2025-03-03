# frozen_string_literal: true

class ProjectMember < ActiveRecord::Base
  # constants
  ROLES = %w[contributor collaborator owner]

  # associations
  belongs_to :project
  belongs_to :user

  # validations
  validates :user, uniqueness: { scope: :project }
  validates :role, inclusion: { in: ROLES, message: "%{value} is not a valid role" }
end
