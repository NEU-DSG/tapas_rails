# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'tapas_rails'
set :repo_url, 'https://github.com/neu-dsg/tapas_rails'

# Ensure that the Rails environment is always loaded for Resque workers
set :resque_environment_task, true

set :scm, :git
set :git_strategy, Capistrano::Git::SubmoduleStrategy
# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

desc "Verify write access on all servers"
task :check_write_permissions do 
  on roles(:all) do |host| 
    if test("[ -w #{fetch(:deploy_to)} ]")
      info "#{fetch(:deploy_to)} is writable on #{host}"
    else
      error "#{fetch(:deploy_to)} is not writable on #{host}"
    end
  end
end

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "/sbin/service tomcat restart"
    end
  end

  desc 'Copy over application.yml from deploy users home directory'
  task :copy_figaro_conf do 
    on roles(:app), in: :sequence, wait: 5 do 
      execute "cp /home/tapas_rails/application.yml #{release_path}/config/" 
    end
  end

  desc 'Create the API user'
  task :create_api_user do 
    on roles(:app), in: :sequence, wait: 5 do 
      execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)}"\
              " ~/.rvm/bin/rvm default do bundle exec thor"\
              " tapas_rails:create_api_user"
    end
  end

  desc 'Create a release specific tmp directory'
  task :create_tmp_dir do 
    on roles(:all), in: :sequence, wait: 5 do 
      execute "cd #{release_path} && mkdir tmp" 
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
