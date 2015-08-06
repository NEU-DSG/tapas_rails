# The use of the content datastream label to store the basename of the 
# file held in that stream has been historically controversial, but I keep
# doing it because so far no better solution has come along.
#
# To ease the eventual migration away from this use this filename method to 
# access the filename of a content object file.
module Filename
  extend ActiveSupport::Concern 

  def filename 
    return self.content.label 
  end
end

