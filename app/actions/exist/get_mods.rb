# Note that this action does NOT return the mods metadata that we store and use
# Rather, it gives us back a MODS record derived from a given TEI File that is
# then immediately passed back to Drupal to populate its 'finalize metadata'
# page.  When the metadata from *this* page is passed through to eXist via the
# UpdateTEIMetadata action, the actual MODS record that both systems will use
# is generated and returned.
class GetMODS
  attr_reader :tei_file_path
  attr_accessor :response

  def initialize(tei_file_path)
    @tei_file_path = tei_file_path
  end

  def self.execute(file_path)
    GetMODS.new(file_path).execute
  end

  def execute 
    response = ExistService.post('mods', {
      :file => File.new(tei_file_path, 'rb')
    })


    case response.status 
    when 200 
      response.body
    end
  end
end
