
class Api::V1::OauthApplicationResource < Api::V1::BaseResource
  model_name 'Doorkeeper::Application'
  model_hint model: Doorkeeper::Application

  attributes :name, :uid, :secret, :redirect_uri, :scopes, :created_at, :updated_at, :is_public

  has_one :owner, polymorphic: true


  set_callback :authorize, :before, :prefix_owner_type

  
  # Overwride default scopes putter because Doorkeeper::Application instances
  # expect scopes to be a single spaces-seperated string
  def scopes= new_scopes
    @model.scopes=new_scopes.join(" ") if new_scopes.respond_to?(:join)
  end  

  private
    def prefix_owner_type
      @model.owner_type="MasterData::#{@model.owner_type}" if @model.owner_type && !@model.owner_type.start_with?("MasterData::") 
    end
end
