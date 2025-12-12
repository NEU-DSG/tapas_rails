# frozen_string_literal: true

class CoreFilesProject < ApplicationRecord
  # This join model is automatically maintained via the CoreFile sync_project_association callback
  # It represents which projects a core file belongs to (derived from its collections)

  belongs_to :project
  belongs_to :core_file

  # Prevent direct manipulation - this table should only be managed via CoreFile callbacks
  validate :prevent_direct_manipulation, on: :create
  validate :ensure_core_file_belongs_to_project_collections, on: :create

  # Note: This table should be treated as read-only from the application perspective
  # The CoreFile model manages these associations via sync_project_association callback

  private

  def prevent_direct_manipulation
    # Allow creation only if called from within the CoreFile model's callback
    # Check the call stack to see if we're being called from sync_project_association
    caller_locations = caller_locations(1, 20)
    allowed_caller = caller_locations.any? do |location|
      location.path.include?('core_file.rb') &&
      (location.label == 'sync_project_association' || location.label == 'project=')
    end

    unless allowed_caller
      errors.add(:base, "CoreFilesProject records can only be created via CoreFile's sync_project_association callback. " \
                        "Add the core file to a collection instead of directly to a project.")
    end
  end

  def ensure_core_file_belongs_to_project_collections
    return unless core_file && project

    # Verify that the core file actually has collections in this project
    core_file_project_ids = core_file.collections.map(&:project_id).compact.uniq

    unless core_file_project_ids.include?(project_id)
      errors.add(:base, "Cannot associate CoreFile #{core_file_id} with Project #{project_id}. " \
                        "Core file's collections belong to project(s): #{core_file_project_ids.join(', ')}")
    end
  end
end
