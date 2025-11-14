# pre-upgrade - 03272023 by CCH

# Suppress deprecation warnings in Ruby 2.7
# - redis-namespace 2.0 compatibility warnings
# - IRB context aliasing warnings
module Kernel
  alias_method :original_warn, :warn
  def warn(*messages)
    filtered = messages.reject { |m| m.to_s =~ /blind passthrough|redis-namespace 2\.0|can't alias context from irb_context/ }
    original_warn(*filtered) unless filtered.empty?
  end
end

# Also override $stderr.puts to filter IRB warnings
class << $stderr
  alias_method :original_puts, :puts
  def puts(*messages)
    filtered = messages.reject { |m| m.to_s =~ /irb.*can't alias context|can't alias context from irb_context/ }
    original_puts(*filtered) unless filtered.empty?
  end

  alias_method :original_write, :write
  def write(message)
    return if message.to_s =~ /irb.*can't alias context|can't alias context from irb_context/
    original_write(message)
  end
end

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

# ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)
#
# require 'bundler/setup' # Set up gems listed in the Gemfile.
# require 'bootsnap/setup' # Speed up boot time by caching expensive operations.

