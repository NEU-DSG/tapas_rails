require 'rails'

module CerberusCore::Concerns::AutoMintedPid
  extend ActiveSupport::Concern 

  included do 
    after_initialize :mint_pid, :on => :create

    private

    def mint_pid
      if Rails.configuration.cerberus_core.auto_generate_pid
        if !(self.persisted?)
          self.send(:assign_pid)
        end
      end
    end
  end
end