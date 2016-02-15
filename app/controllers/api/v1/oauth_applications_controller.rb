class Api::V1::OauthApplicationsController < Api::V1::BaseController
  include Oauthable

  before_action :set_application, only: [:show, :update, :destroy, :reset_secret]
  before_action :set_debug_headers

  
  # GET /api/v1/oauth_applications.json
  scopes :index, 'scopes.oauth_apps.manage'

  # GET /api/v1/oauth_applications/1.json
  scopes :show, 'scopes.oauth_apps.manage'

  # POST /api/v1/oauth_applications.json
  scopes :create, 'scopes.oauth_apps.manage', 'scopes.profiles.oauth_apps.readwrite'

  # PATCH/PUT /api/v1/oauth_applications/1.json
  scopes :update, 'scopes.oauth_apps.manage'

  # DELETE /api/v1/oauth_applications/1.json
  scopes :destroy, 'scopes.oauth_apps.manage'

  # PATCH/PUT /api/v1/oauth_applications/1/reset_secret.json
  scopes :reset_secret, 'scopes.oauth_apps.manage'
  def reset_secret
      @application.secret = Doorkeeper::OAuth::Helpers::UniqueToken.generate

      if @application.save
        render :show
      else
        render json: @application.errors, status: :unprocessable_entity
      end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_application
      @application = Doorkeeper::Application.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def application_params
      params.require(:data).require(:attributes).permit(:id, :name, :redirect_uri, :scopes, scopes: [])
    end

end