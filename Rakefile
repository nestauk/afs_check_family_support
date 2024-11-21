# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

unless Rails.env.production?
  require "standard/rake"
  Rake::Task["test"].enhance(%i[standard])
  Rake::Task["test"].enhance do
    Rake::Task["test:system"].invoke
  end
end
