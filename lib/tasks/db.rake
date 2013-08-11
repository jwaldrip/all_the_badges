namespace :db do
  task :recreate => ['db:drop', 'db:create', 'db:migrate', 'db:test:prepare']
end
