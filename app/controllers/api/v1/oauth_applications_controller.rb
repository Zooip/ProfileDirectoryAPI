class Api::V1::OauthApplicationsController < Api::V1::BaseController
  include Oauthable

  before_action :set_application, only: [:reset_secret]
  before_action :set_debug_headers

  
  # GET /api/v1/oauth_applications.json
  scopes :index, 'scopes.oauth_apps.manage', 'scopes.oauth_apps.public.readonly' 

  # GET /api/v1/oauth_applications/1.json
  scopes :show, 'scopes.oauth_apps.manage', 'scopes.oauth_apps.public.readonly', 'scopes.profiles.oauth_apps.readonly', 'scopes.profiles.oauth_apps.readwrite'

  # POST /api/v1/oauth_applications.json
  scopes :create, 'scopes.oauth_apps.manage', 'scopes.profiles.oauth_apps.readwrite'

  # PATCH/PUT /api/v1/oauth_applications/1.json
  scopes :update, 'scopes.oauth_apps.manage','scopes.profiles.oauth_apps.readwrite'

  # DELETE /api/v1/oauth_applications/1.json
  scopes :destroy, 'scopes.oauth_apps.manage','scopes.profiles.oauth_apps.readwrite'


  scopes :update_relationship, 'scopes.oauth_apps.manage'
  scopes :create_relationship, 'scopes.oauth_apps.manage'
  scopes :destroy_relationship, 'scopes.oauth_apps.manage'
  scopes :show_relationship, 'scopes.oauth_apps.manage', 'scopes.oauth_apps.public.readonly', 'scopes.profiles.oauth_apps.readonly', 'scopes.profiles.oauth_apps.readwrite'
  scopes :get_related_resource, 'scopes.oauth_apps.manage', 'scopes.oauth_apps.public.readonly', 'scopes.profiles.oauth_apps.readonly', 'scopes.profiles.oauth_apps.readwrite'

  # POST /api/v1/oauth_applications/1/reset_secret.json
  scopes :reset_secret, 'scopes.oauth_apps.manage','scopes.profiles.oauth_apps.readwrite'
  def reset_secret

      policy = Pundit.policy!(doorkeeper_token, @application)
      raise Pundit::NotAuthorizedError.new(query: "update?", record: @application, policy: policy) unless policy.update? 
      @application.secret = Doorkeeper::OAuth::Helpers::UniqueToken.generate

      if @application.save
        redirect_to api_v1_oauth_application_path(@application)
      else
        render json: @application.errors, status: :unprocessable_entity
      end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_application
      @application = Pundit.policy_scope(doorkeeper_token,Doorkeeper::Application).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def application_params
      params.require(:data).require(:attributes).permit(:id, :name, :redirect_uri, :scopes, scopes: [])
    end

end