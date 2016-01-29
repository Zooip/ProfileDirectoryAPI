include Rails.application.routes.url_helpers

class MasterData::ProfileSerializer < ActiveModel::Serializer
  type 'profiles'
  attributes :id, :first_name, :last_name, :birth_last_name, :full_name, :email, :soce_id, :birth_date, :death_date

  has_many :connection_aliases, if: :admin?

  def full_name
    [object.first_name,object.last_name].compact.join(" ")
  end

  def _links
    {self: api_v1_profile_url(object)}
  end

  # def included
  #   [:connection_aliases]
  # end

  # def filter(keys)
  #   if serializer_scope[:fields].any?
  #     keys & serializer_scope[:fields]
  #   else
  #     keys & serializer_scope[:fields]
  #   end

  # end

  # def debug
  #   {
  #     scope: serializer_scope
  #   }
  # end

  def admin?
    !(!(serializer_scope[:admin]))
  end

end
