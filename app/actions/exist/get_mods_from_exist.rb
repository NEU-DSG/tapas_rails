# Takes a filepath pointing at a TEI XML document and sends it to eXist.
# Returns a raw string of the resulting XML data.
# Does not move, delete, modify, or validate the file you provide.
class GetMODSFromExist
  attr_reader :mods_filepath

  def initialize(mods_filepath)
    @mods_filepath = mods_filepath
  end

  def self.execute(mods_filepath)
    self.new(mods_filepath).execute
  end

  def execute
    "<dummy> I don't do anything! </dummy>"
  end
end
