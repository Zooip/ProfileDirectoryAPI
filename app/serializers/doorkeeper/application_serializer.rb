include Rails.application.routes.url_helpers

class Doorkeeper::ApplicationSerializer < ActiveModel::Serializer
  type 'oauth_applications'

  attributes :id, :name, :uid, :secret, :redirect_uri, :scopes, :created_at, :updated_at

  has_one :owner

  link :self do
    api_v1_oauth_application_url(object, format: :json)
  end

  link :reset_secret do
    reset_secret_api_v1_oauth_application_url(object, format: :json)
  end

end
