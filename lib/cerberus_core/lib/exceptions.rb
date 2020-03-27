module CerberusCore
  class PidNotFoundInSolrError < StandardError ; end 
  class BadDirectoryNameError < StandardError ; end 
  class BadFileNameError < StandardError ; end
  class InvalidExistInteractionError < StandardError ; end
  class InvalidConfigurationError < StandardError ; end
end