
class Api::V1::OauthApplicationResource < Api::V1::BaseResource
  model_name 'Doorkeeper::Application'
  model_hint model: Doorkeeper::Application

  attributes :name, :uid, :secret, :redirect_uri, :scopes, :created_at, :updated_at, :is_public

  has_one :owner, polymorphic: true

  set_callback :save, :before, :authorize_save
  
  # Authorize the model for the permission required by the controller
  # action. Also, mark the controller as having been policy authorized.
  def authorize_save
    policy = Pundit.policy!(context.fetch(:current_token), @model)

    unless policy.public_send(:create?)
      raise Pundit::NotAuthorizedError.new(query:'create?', record: @model, policy: policy)
    end
  end

  # Overwride default scopes putter because Doorkeeper::Application instances
  # expect scopes to be a single spaces-seperated string
  def scopes= new_scopes
    @model.scopes=new_scopes.join(" ") if new_scopes.respond_to?(:join)
  end  
end
