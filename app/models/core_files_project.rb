# frozen_string_literal: true

class CoreFilesProject < ApplicationRecord
  # This join model is automatically maintained via the CoreFile sync_project_association callback
  # It represents which projects a core file belongs to (derived from its collections)

  belongs_to :project
  belongs_to :core_file

  # Note: This table should be treated as read-only from the application perspective
  # The CoreFile model manages these associations via sync_project_association callback
end
