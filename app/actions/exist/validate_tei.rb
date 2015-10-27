# Sends a mods request with the given tei.  Parses 
# a response indicating errors into an array of TEI 
# validation errors, otherwise returns an empty
# array
module Exist
  class ValidateTei
    include Exist::Concerns::Helpers
    include Exist::Concerns::Mods

    def self.execute(tei_filepath)
      self.new(tei_filepath).execute
    end

    def initialize(tei_filepath)
      @tei_filepath = tei_filepath
      @opts = {}
    end

    def execute
      build_resource(build_url('derive-mods'))

      begin
        response = send_mods_request
        return []
      rescue RestClient::Exception => e
        if e.http_code == 422
          Nokogiri::HTML(e.response).css('li').map { |li| li.text }
        else
          raise e 
        end
      end
    end
  end
end
