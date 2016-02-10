class Api::V1::OauthApplicationsController < Api::V1::BaseController
  include Oauthable

  before_action :set_application, only: [:show, :update, :destroy, :reset_secret]
  before_action :set_debug_headers

  
  # GET /api/v1/profiles.json
  scopes :index, 'scopes.admin'

  # GET /api/v1/profiles/1.json
  scopes :show, 'scopes.admin'

  # POST /api/v1/profiles.json
  scopes :create, 'scopes.admin'


  # PATCH/PUT /api/v1/profiles/1.json
  scopes :update, 'scopes.admin'

  # DELETE /api/v1/profiles/1.json
  scopes :destroy, 'scopes.admin'

  # PATCH/PUT /api/v1/profiles/1/reset_secret.json
  scopes :reset_secret, 'scopes.admin'
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