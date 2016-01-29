class Api::V1::ProfilesController < Api::V1::BaseController
  before_action :set_master_data_profile, only: [:show, :update, :destroy]
  before_action :set_debug_headers


  # GET /master_data/profiles.json
  def index
    @master_data_profiles = MasterData::Profile.where(filter_params).includes(include_params).paginate(page_params)
    render json: @master_data_profiles, fields: fields_params, include: include_params, links: { create: Rails.application.routes.url_helpers.api_v1_profiles_url}
  end


  # GET /master_data/profiles/1.json
  def show
    render json: @master_data_profile, fields: fields_params, include: include_params
  end

  # POST /master_data/profiles.json
  def create
    @master_data_profile = MasterData::Profile.new(master_data_profile_params)

    respond_to do |format|
      if @master_data_profile.save
        format.json { render :show, status: :created, location: api_v1_profile_url(@master_data_profile) }
      else
        format.json { render json: @master_data_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /master_data/profiles/1
  # PATCH/PUT /master_data/profiles/1.json
  def update
    respond_to do |format|
      if @master_data_profile.update(master_data_profile_params)
        format.json { render :show, status: :ok, location: api_v1_profile_url(@master_data_profile) }
      else
        format.json { render json: @master_data_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /master_data/profiles/1
  # DELETE /master_data/profiles/1.json
  def destroy
    @master_data_profile.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_master_data_profile
      @master_data_profile = MasterData::Profile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def master_data_profile_params
      params.require(:profile).permit(:soce_id, :first_name, :last_name, :birth_last_name, :gender, :email, :birth_date, :death_date, :login_validation_check, :description, :created_at, :updated_at, :encrypted_password)
    end
end


