class Api::V1::PhoneNumberResource < Api::V1::BaseResource
  model_name 'MasterData::PhoneNumber'
  model_hint model: MasterData::PhoneNumber

  attributes :number,:country_code, :format

  has_one :profile

end
