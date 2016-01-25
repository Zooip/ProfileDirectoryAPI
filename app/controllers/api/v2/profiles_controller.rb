class Api::V2::ProfilesController < ApplicationController
  before_action :set_gram_profile, only: [:show, :update, :destroy]

  # GET /gram/profiles.json
  def index
    @gram_profiles = Gram::Profile.all
  end


  # GET /gram/profiles/1.json
  def show
  end

  # POST /gram/profiles.json
  def create
    @gram_profile = Gram::Profile.new(gram_profile_params)

    respond_to do |format|
      if @gram_profile.save
        format.json { render :show, status: :created, location: api_v2_profile_url(@gram_profile) }
      else
        format.json { render json: @gram_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gram/profiles/1
  # PATCH/PUT /gram/profiles/1.json
  def update
    respond_to do |format|
      if @gram_profile.update(gram_profile_params)
        format.json { render :show, status: :ok, location: api_v2_profile_url(@gram_profile) }
      else
        format.json { render json: @gram_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gram/profiles/1
  # DELETE /gram/profiles/1.json
  def destroy
    @gram_profile.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gram_profile
      @gram_profile = Gram::Profile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gram_profile_params
      params.require(:profile).permit(:soce_id, :first_name, :last_name, :birth_last_name, :gender, :email, :birth_date, :death_date, :login_validation_check, :description, :created_at, :updated_at, :encrypted_password)
    end
end


