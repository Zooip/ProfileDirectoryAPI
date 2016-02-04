class Api::V1::OauthApplicationsController < Api::V1::BaseController
  include Oauthable
  #scopes_attributes(
  set_serializer Doorkeeper::ApplicationSerializer

  before_action :set_application, only: [:show, :update, :destroy, :reset_secret]
  before_action :set_debug_headers
  before_action only: [:create, :update] do 
    verify_type 'oauth_applications'
  end

  
  # GET /api/v1/profiles.json
  scopes :index, 'scopes.admin'
  def index
    @application = Doorkeeper::Application.where(filter_params).includes(include_params).paginate(page_params)
    render json: @application, fields: serializer_fields, include: include_params
  end

  # GET /api/v1/profiles/1.json
  scopes :show, 'scopes.admin'
  def show
    render json: @application, fields: serializer_fields, include: include_params
  end

  # POST /api/v1/profiles.json
  scopes :create, 'scopes.admin'
  def create
    a_params=application_params
    a_params[:scopes]=a_params[:scopes].join(" ") if a_params[:scopes] && a_params[:scopes].respond_to?(:join)

    @application = Doorkeeper::Application.new(a_params)

    if @application.save
      render status: :created, json: @application, fields: serializer_fields, include: include_params
    else
      render json: @application.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/profiles/1.json
  scopes :update, 'scopes.admin'
  def update
      a_params=application_params
      a_params[:scopes]=a_params[:scopes].join(" ") if a_params[:scopes] && a_params[:scopes].respond_to?(:join)

      if @application.update(a_params)
        render status: :ok, json: @application, fields: serializer_fields, include: include_params
      else
        render json: @application.errors, status: :unprocessable_entity
      end
  end

  # DELETE /api/v1/profiles/1.json
  scopes :destroy, 'scopes.admin'
  def destroy
    @application.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  # PATCH/PUT /api/v1/profiles/1/reset_secret.json
  scopes :reset_secret, 'scopes.admin'
  def reset_secret
      @application.secret = Doorkeeper::OAuth::Helpers::UniqueToken.generate

      if @application.save
        render status: :ok, json: @application, fields: serializer_fields, include: include_params
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