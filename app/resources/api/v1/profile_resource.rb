class Api::V1::ProfileResource < JSONAPI::Resource
  model_name 'MasterData::Profile'

  # def id
  #   @model.uuid
  # end

  attributes :id, :soce_id,:email, :first_name, :last_name, :gender
end
