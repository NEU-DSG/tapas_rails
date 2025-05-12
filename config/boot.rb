ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
# require 'bootsnap/setup' do |config|
#   config.cache_dir = 'tmp/cache'
#   config.development_mode = ENV['RAILS_ENV'] == 'development'
#   config.load_path_cache = true
#   config.autoload_paths_cache = true
#   config.disable_trace = true
#   config.compile_cache_iseq = true
#   config.compile_cache_yaml = true
# end
