# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

# role :app, %w{tapasdev.neu.edu}
# role :web, %w{tapasdev.neu.edu}
# role :db,  %w{tapasdev.neu.edu}


# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

# parses out the current branch you're on. See: http://www.harukizaemon.com/2008/05/deploying-branches-with-capistrano.html
current_branch = `git branch`.match(/\* (\S+)\s/m)[1]

# use the branch specified as a param, then use the current branch. If all fails use master branch
set :branch, ENV['branch'] || current_branch || "develop" # you can use the 'branch' parameter on deployment to specify the branch you wish to deploy

server 'tapasdev.neu.edu', user: 'tapas_rails', roles: %w{web app db resque_worker resque_scheduler}

set :workers, { "tapas_rails" => 2, "tapas_rails_maintenance" => 2 }

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }


set :deploy_to, '/export/home/tapas_rails/tapas_rails'
# set :branch, 'develop'
set :rails_env, 'staging'
set :stage, :staging

set :resque_log_file, 'log/resque.log'

set :passenger_in_gemfile, true
set :passenger_restart_options, -> { "#{current_path} --ignore-app-not-running" }
set :passenger_environment_variables, { :path => '/export/home/tapas_rails/tapas_rails/shared/bundle/ruby/2.0.0/gems/passenger-5.0.15/bin:$PATH' }
set :passenger_restart_command, '/export/home/tapas_rails/tapas_rails/shared/bundle/ruby/2.0.0/gems/passenger-5.0.15/bin/passenger-config restart-app'

# set :passenger_restart_with_touch, false

after 'deploy:restart', 'resque:restart'
after 'deploy:updating', 'deploy:copy_figaro_conf'
after 'deploy:published', 'deploy:create_api_user'
after 'deploy:published', 'deploy:load_view_packages'
after 'deploy:published', 'deploy:create_tmp_dir'
