json.array!(@gram_profiles) do |gram_profile|
  json.extract! gram_profile, :id, :soce_id, :first_name, :last_name, :birth_last_name, :gender, :email, :birth_date, :death_date, :login_validation_check, :description, :created_at, :updated_at
  json.url api_v2_profile_url(gram_profile, format: :json)
end
