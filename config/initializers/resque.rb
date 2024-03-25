require 'rake'

Rails.application.config.after_initialize do
    Rake::Task['start_tasks:worker_startup_task'].invoke if Rails.env.in?(%w[development production test])
end
