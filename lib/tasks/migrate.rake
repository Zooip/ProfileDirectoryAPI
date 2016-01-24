
namespace :gram do
  namespace :db do
    desc 'Migrates the your_engine database'
    task :migrate => :environment do
      with_gram_connection do
        ActiveRecord::Migrator.migrate("db/migrate/gram_db/")
      end
    end
  end
end

# Hack to temporarily connect AR::Base to your engine.
def with_gram_connection
  original = ActiveRecord::Base.remove_connection
  ActiveRecord::Base.establish_connection GRAM_DB_CONF
  yield
ensure
  ActiveRecord::Base.establish_connection original
end
