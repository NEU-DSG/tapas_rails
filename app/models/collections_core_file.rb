# frozen_string_literal: true

class CollectionsCoreFile < ApplicationRecord
  # This join model enforces business rules for the CoreFile-Collection relationship

  belongs_to :collection
  belongs_to :core_file

  # Validate that we're not creating an association that would cause
  # the core file to belong to multiple projects
  validate :ensure_single_project, on: :create

  private

  def ensure_single_project
    return unless core_file && collection

    # Get all existing project IDs for this core file through its collections
    existing_project_ids = core_file.collections.map(&:project_id).compact.uniq
    new_project_id = collection.project_id

    # If this core file already has collections, ensure new collection is from same project
    if existing_project_ids.any? && !existing_project_ids.include?(new_project_id)
      errors.add(:base, "Core file cannot belong to collections from multiple projects. " \
                        "Existing project(s): #{existing_project_ids.join(', ')}, " \
                        "attempted to add project: #{new_project_id}")
    end
  end
end
