module CerberusCore::Datastreams
  # A datastream for holding an actual content blob.  Notable for providing
  # the ExtractMetadata module, which is used for FITS characterization. 
  class FileContentDatastream < ActiveFedora::Datastream
    include Hydra::Derivatives::ExtractMetadata

    def prefix
      ""
    end
  end
end
