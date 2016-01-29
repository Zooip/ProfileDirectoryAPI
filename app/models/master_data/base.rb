module MasterData
  class Base < ActiveRecord::Base
    self.abstract_class = true
    establish_connection MASTER_DATA_DB_CONF
  end
end