class Api::V1::ProfilesController < Api::V1::BaseController
  include Oauthable

  before_action :set_profile, only: [:show, :update, :destroy]
  before_action :set_debug_headers
  before_action only: [:create, :update] do 
    verify_type 'profiles'
  end

  
  # GET /api/v1/profiles.json
  scopes :index, 'scopes.profiles', 'scopes.profiles.readonly'
  def index
    @profiles = MasterData::Profile.where(filter_params).includes(include_params).paginate(page_params)
    render json: @profiles, fields: fields_params, include: include_params, links: { create: Rails.application.routes.url_helpers.api_v1_profiles_url}
  end


  # GET /api/v1/profiles/1.json
  scopes :show, 'scopes.profiles', 'scopes.profiles.readonly'
  def show
    render json: @profile, fields: fields_params, include: include_params
  end

  # POST /api/v1/profiles.json
  scopes :create, 'scopes.profiles'
  def create
    @profile = MasterData::Profile.new(profile_params)

    if @profile.save
      render status: :created, json: @profile, fields: fields_params, include: include_params
    else
      render json: @profile.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/profiles/1
  # PATCH/PUT /api/v1/profiles/1.json
  scopes :update, 'scopes.profiles'
  def update
      if @profile.update(profile_params)
        render status: :ok, json: @profile, fields: fields_params, include: include_params
      else
        render json: @profile.errors, status: :unprocessable_entity
      end
  end

  # DELETE /api/v1/profiles/1
  # DELETE /api/v1/profiles/1.json
  scopes :destroy, 'scopes.profiles'
  def destroy
    @profile.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      @profile = MasterData::Profile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      params.require(:data).require(:attributes).permit(:soce_id, :first_name, :last_name, :birth_last_name, :gender, :email, :birth_date, :death_date, :login_validation_check, :description, :encrypted_password)
    end

end


