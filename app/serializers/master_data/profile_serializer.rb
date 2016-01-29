include Rails.application.routes.url_helpers

class MasterData::ProfileSerializer < ActiveModel::Serializer
  type 'profiles'
  attributes :id, :first_name, :last_name, :birth_last_name, :full_name, :email, :soce_id, :birth_date, :death_date

  has_many :connection_aliases

  def full_name
    [object.first_name,object.last_name].compact.join(" ")
  end

  def _links
    {self: api_v1_profile_url(object, format: :json)}
  end

end
