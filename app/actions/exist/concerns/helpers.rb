module Exist
  module Concerns
    module Helpers
      extend ActiveSupport::Concern

      included do 
        attr_accessor :resource 
      end

      def exist_logger
        @@exist_logger ||= Logger.new("#{Rails.root}/log/#{Rails.env}_exist.log")
      end

      # RestClient does an interesting thing where non-200 status codes are
      # intercepted and turned into a fairly generic exception, which makes 
      # it impossible to know what error was raised and what the response 
      # was.
      def send_request
        begin
          yield
        rescue RestClient::Exception => e
          exist_logger.error("#{e.http_code} error raised. \n"\
                             "Response was: \n #{e.response}")
          raise e
        end
      end

      def build_url(url_fragment)
        base = Settings['exist']['url']

        if url_fragment.starts_with? '/'
          url_fragment = url_fragment[1..-1]
        end

        "#{base}/#{url_fragment}"
      end

      def options_hash
        { :user => Settings['exist']['username'], 
          :password => Settings['exist']['password'],
          :headers => Hash.new } 
      end
    end
  end
end
