# frozen_string_literal: true

class ProjectCollection < ActiveRecord::Base
  belongs_to :project
  belongs_to :collection
end
