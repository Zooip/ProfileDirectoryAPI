

namespace :db do
  desc "Migrate all databases"
  Rake::Task['db:migrate'].clear
  task :migrate do
    Rake::Task["db:migrate_api"].invoke
    Rake::Task["db:migrate_gram"].invoke
  end

  desc "Perform migrations on API database"
  task :migrate_api do
    puts 'Migrating API Database'
    ActiveRecord::Base.establish_connection API_DB_CONF
    ActiveRecord::Migrator.migrate("db/migrate/api_db")
  end

  desc "Perform migrations on GrAM database"
  task :migrate_gram do
    puts 'Migrating Rails Database'
    ActiveRecord::Base.establish_connection GRAM_DB_CONF
    ActiveRecord::Migrator.migrate("db/migrate/gram_db/")
  end
end