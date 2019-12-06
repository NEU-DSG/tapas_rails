# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

# role :app, %w{tapas.neu.edu}
# role :web, %w{tapas.neu.edu}
# role :db,  %w{tapas.neu.edu}


# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

server 'tapas.neu.edu', user: 'tapas_rails', roles: %w{web app db resque_worker resque_scheduler}

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
set :branch, 'develop'
set :rails_env, 'production'

set :resque_log_file, 'log/resque.log'

set :passenger_in_gemfile, true
set :passenger_restart_options, -> { "#{current_path} --ignore-app-not-running" }

after 'deploy:restart', 'resque:restart'
after 'deploy:updating', 'deploy:copy_figaro_conf'
after 'deploy:published', 'deploy:create_api_user'
after 'deploy:published', 'deploy:create_tmp_dir'
