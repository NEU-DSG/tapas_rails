# frozen_string_literal: true

class CollectionCoreFile < ActiveRecord::Base
  belongs_to :collection
  belongs_to :core_file
end
