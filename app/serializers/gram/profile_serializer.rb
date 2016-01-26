class Gram::ProfileSerializer < ActiveModel::Serializer
  attributes :id, :names, :email, :birth_date, :death_date, :_links

  def names
    {
      first_name: object.first_name,
      last_name: object.last_name,
      birth_last_name: object.birth_last_name,
      full_name: "#{object.first_name} #{object.last_name}"
    }
  end

  def _links
    {
      self: {
        href: api_v2_profile_url(object)
      },
      index: {
        href: api_v2_profiles_url
      },
    }
  end

end
