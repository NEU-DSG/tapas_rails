# Takes a filepath pointing at a TEI XML document and sends it to eXist.
# Returns a raw string of the resulting XML data.
# Does not move, delete, modify, or validate the file you provide.
class GetMODSFromExist
  include ExistActions

  attr_reader :tei_filepath

  def initialize(tei_filepath)
    @tei_filepath = tei_filepath
  end

  def self.execute(tei_filepath)
    self.new(tei_filepath).execute
  end

  def build_resource 
    url = ExistActions.build_url 'derive-mods'
    hash = ExistActions.options_hash 

    hash[:headers][:content_type] = 'application/xml'
    hash[:headers][:accept] = 'application/xml'

    self.resource = RestClient::Resource.new(url, hash)
  end

  def execute
    build_resource
    resource.post File.read(tei_filepath)
  end
end
