# Module MasterData defines models for data stored in the Master Data database.
# Here lies the organisation logic and API-Engine implementation details should not impact it
# Therefore, updating API-Engine version should not impact MasterData Models
#
module MasterData
  def self.table_name_prefix
    ''
  end
end
