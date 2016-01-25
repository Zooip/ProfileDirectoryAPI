class Api::ProfilesController < ApplicationController
  before_action :set_gram_profile, only: [:show, :edit, :update, :destroy]

  # GET /gram/profiles
  # GET /gram/profiles.json
  def index
    @gram_profiles = Gram::Profile.all
  end

  # GET /gram/profiles/1
  # GET /gram/profiles/1.json
  def show
  end

  # GET /gram/profiles/new
  def new
    @gram_profile = Gram::Profile.new
  end

  # GET /gram/profiles/1/edit
  def edit
  end

  # POST /gram/profiles
  # POST /gram/profiles.json
  def create
    @gram_profile = Gram::Profile.new(gram_profile_params)

    respond_to do |format|
      if @gram_profile.save
        format.html { redirect_to @gram_profile, notice: 'Profile was successfully created.' }
        format.json { render :show, status: :created, location: @gram_profile }
      else
        format.html { render :new }
        format.json { render json: @gram_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gram/profiles/1
  # PATCH/PUT /gram/profiles/1.json
  def update
    respond_to do |format|
      if @gram_profile.update(gram_profile_params)
        format.html { redirect_to @gram_profile, notice: 'Profile was successfully updated.' }
        format.json { render :show, status: :ok, location: @gram_profile }
      else
        format.html { render :edit }
        format.json { render json: @gram_profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gram/profiles/1
  # DELETE /gram/profiles/1.json
  def destroy
    @gram_profile.destroy
    respond_to do |format|
      format.html { redirect_to gram_profiles_url, notice: 'Profile was successfully destroyed.' }
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
      params.require(:gram_profile).permit(:soce_id, :first_name, :last_name, :birth_last_name, :gender, :email, :birth_date, :death_date, :login_validation_check, :description, :created_at, :updated_at)
    end
end
