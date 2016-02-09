
class Api::V1::OauthApplicationResource < JSONAPI::Resource
  model_name 'Doorkeeper::Application'
  model_hint model: Doorkeeper::Application

  attributes :id, :name, :uid, :secret, :redirect_uri, :scopes, :created_at, :updated_at

  has_one :owner, polymorphic: true, class_name:'Profiles'


  def scopes= new_scopes
    @model.scopes=new_scopes.join(" ") if new_scopes.respond_to?(:join)
  end
end
