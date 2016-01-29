class MasterData::ConnectionAliasSerializer < ActiveModel::Serializer
  type 'connection_aliases'
  attributes :id, :connection_alias
  belongs_to :profile

  def _links
    {self: api_v1_connection_alias_url(object, format: :json)}
  end
end
