# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

require 'capistrano/rvm'

require 'capistrano/bundler'

require 'capistrano/rails/migrations'

require 'capistrano-resque'

require 'capistrano/passenger'

require 'capistrano/git-submodule-strategy'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
