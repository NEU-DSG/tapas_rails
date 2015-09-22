module Exist
  module Concerns
    module Mods
      extend ActiveSupport::Concern 

      included do 
        attr_reader :tei_filepath, :opts
      end

      def build_resource(url)
        hash = options_hash

        hash[:headers][:content_type] = 'multipart/form-data'
        hash[:headers][:accept] = 'application/xml'

        self.resource = RestClient::Resource.new(url, hash)
      end

      def send_mods_request
        post_params = {}

        post_params[:file] = File.read(tei_filepath)
        add_param(post_params, :contributors)
        add_param(post_params, :authors)
        add_param(post_params, :date, :"timeline-date")
        add_param(post_params, :title)

        send_request { resource.post post_params }
      end

      private

        def add_param(hsh, param, mapping = nil)
          return nil unless opts[param].present?

          # If opts[param] is multivalued, join with |, 
          # otherwise leave alone
          if opts[param].respond_to? :join
            value = opts[param].join(' | ')
          else
            value = opts[param]
          end

          hsh[(mapping || param)] = value
        end
    end
  end
end
