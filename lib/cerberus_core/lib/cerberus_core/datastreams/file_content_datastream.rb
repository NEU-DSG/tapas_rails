module CerberusCore::Datastreams
  # A datastream for holding an actual content blob.  Notable for providing
  # the ExtractMetadata module, which is used for FITS characterization.
  class FileContentDatastream < ActiveFedora::NomDatastream
    def prefix
      ""
    end

    # ExtractMetadata was removed from Hydra::Derivatives in 2015,
    # so we've copied its methods below for now
    def extract_metadata
      return unless has_content?
      Hydra::FileCharacterization.characterize(content, filename_for_characterization.join(""), :fits) do |config|
        config[:fits] = Hydra::Derivatives.fits_path
      end
    end

    protected

    def filename_for_characterization
      registered_mime_type = MIME::Types[mime_type].first
      Logger.warn "Unable to find a registered mime type for #{mime_type.inspect} on #{uri}" unless registered_mime_type
      extension = registered_mime_type ? ".#{registered_mime_type.extensions.first}" : ''
      version_id = 1 # TODO fixme
      m = /\/([^\/]*)$/.match(uri)
      ["#{m[1]}-#{version_id}", "#{extension}"]
    end
  end
end
