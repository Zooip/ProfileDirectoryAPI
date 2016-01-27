include Rails.application.routes.url_helpers

class Gram::ProfileSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :birth_last_name, :full_name, :email, :soce_id, :birth_date, :death_date,

  def full_name
    [object.first_name,object.last_name].compact.join(" ")
  end

  def _links
    {self: api_v2_profile_url(object)}
  end

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

end
