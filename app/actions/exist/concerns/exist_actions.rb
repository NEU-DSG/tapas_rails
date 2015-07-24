module ExistActions
  extend ActiveSupport::Concern

  included do 
    attr_accessor :resource 

    def self.build_url(url_fragment)
      base = Settings['exist']['url']

      if url_fragment.starts_with? '/'
        url_fragment = url_fragment[1..-1]
      end

      "#{base}/#{url_fragment}"
    end
  end


  def self.build_url(url_fragment)
    base = Settings['exist']['url']

    if url_fragment.starts_with? '/'
      url_fragment = url_fragment[1..-1]
    end

    "#{base}/#{url_fragment}"
  end

  def self.options_hash
    { :user => Settings['exist']['username'], 
      :password => Settings['exist']['password'],
      :headers => Hash.new } 
  end
end
