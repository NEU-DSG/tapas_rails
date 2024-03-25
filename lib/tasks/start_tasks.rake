require 'resque'
require 'resque/tasks'

namespace :start_tasks do
  desc "Start Resque workers"
  task :worker_startup_task do
    system("QUEUE=* rake resque:work")
  end
end
