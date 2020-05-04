module CerberusCore::Concerns::HasCoreFiles
  extend ActiveSupport::Concern

  included do
    @core_file_types = [] 

    def self.core_file_types
      @core_file_types || [] 
    end

    def self.has_core_file_types(arry)
      @core_file_types = arry 
    end
  end
end