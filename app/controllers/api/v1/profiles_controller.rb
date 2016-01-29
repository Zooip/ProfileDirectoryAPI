class Api::V1::ProfilesController < Api::V1::BaseController
  include Oauthable

  before_action :set_profile, only: [:show, :update, :destroy]
  before_action :set_debug_headers

  
  # GET /master_data/profiles.json
  scopes :index, 'scopes.profiles', 'scopes.profiles.readonly'
  def index
    @profiles = MasterData::Profile.where(filter_params).includes(include_params).paginate(page_params)
    render json: @profiles, fields: fields_params, include: include_params, links: { create: Rails.application.routes.url_helpers.api_v1_profiles_url}
  end


  # GET /master_data/profiles/1.json
  scopes :show, 'scopes.profiles', 'scopes.profiles.readonly'
  def show
    render json: @profile, fields: fields_params, include: include_params
  end

  # POST /master_data/profiles.json
  scopes :create, 'scopes.profiles'
  def create
    @profile = MasterData::Profile.new(profile_params)

    respond_to do |format|
      if @profile.save
        format.json { render :show, status: :created, location: api_v1_profile_url(@profile) }
      else
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /master_data/profiles/1
  # PATCH/PUT /master_data/profiles/1.json
  scopes :update, 'scopes.profiles'
  def update
    respond_to do |format|
      if @profile.update(profile_params)
        format.json { render :show, status: :ok, location: api_v1_profile_url(@profile) }
      else
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /master_data/profiles/1
  # DELETE /master_data/profiles/1.json
  scopes :delete, 'scopes.profiles'
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
      params.require(:profile).permit(:soce_id, :first_name, :last_name, :birth_last_name, :gender, :email, :birth_date, :death_date, :login_validation_check, :description, :created_at, :updated_at, :encrypted_password)
    end

end


