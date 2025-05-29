# frozen_string_literal: true

class ProjectMember < ApplicationRecord
  # constants
  ROLES = %w[contributor owner]

  # associations
  belongs_to :project
  belongs_to :user

  # validations
  validates :user, uniqueness: { scope: :project }
  validates :role, inclusion: { in: ROLES, message: "%{value} is not a valid role" }

  # callbacks
  after_update :membership

  def is_depositor?
    project.depositor == user ? update(depositor?: true) : nil
  end

  def membership
    if (project.owners.empty? && is_depositor?) || owner?
      update(
        contributor?: false,
        role: 'owner'
      )
    else
      update(
        owner?: false,
        role: 'contributor'
      )
    end
  end

  def self.owners(project)
    where(role: 'owner', owner?: true, project: project)
  end

  def self.user_projects(user, roles = nil)
    query = where(user: user)
    query = roles.present? ? query.where(role: roles) : query

    query.includes(:project).map(&:project)
  end

  def self.projects_by_role(user)
    projects = user_projects(user)
    user_projects_by_role = {}

    ROLES.each do |role|
      user_projects_by_role[role] = projects.select { |p| ProjectMember.where(project: p, user: user, role: role) }
    end

    user_projects_by_role
  end

  def has_role?(role_name)
    role == role_name
  end
end
