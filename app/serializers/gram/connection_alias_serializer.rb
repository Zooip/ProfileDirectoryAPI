class Gram::ConnectionAliasSerializer < ActiveModel::Serializer
  type 'connection_aliases'
  attributes :id, :connection_alias
  belongs_to :profile

  def _links
    {self: api_v2_connection_alias_url(object)}
  end
end
