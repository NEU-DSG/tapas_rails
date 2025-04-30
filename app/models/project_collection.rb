# frozen_string_literal: true

class ProjectCollection < ApplicationRecord
  belongs_to :project
  belongs_to :collection
end
