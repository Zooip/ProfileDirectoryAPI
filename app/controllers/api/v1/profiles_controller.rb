class Api::V1::ProfilesController < Api::V1::BaseController
  include Oauthable
  scopes_attributes({ 'scopes.profiles.basic.readwrite'    => {read:  {profiles: [:id, :soce_id,:email, :first_name, :last_name, :gender]},
                                                               write: {profiles: [:email, :encrypted_password]}},
                      'scopes.profiles.basic.readonly'     => {read:  {profiles: [:id, :soce_id,:email, :first_name, :last_name, :gender]}},
                      'scopes.profiles.civility.readwrite' => {read:  {profiles: [:birth_last_name,:birth_date,:death_date, :encrypted_password]},
                                                               write: {profiles: [:birth_last_name,:birth_date,:death_date, :encrypted_password]}},
                      'scopes.profiles.civility.readonly'  => {read:  {profiles: [:birth_last_name,:birth_date,:death_date]}}
                    })

  before_action :set_profile, only: [:show, :update, :destroy]
  before_action :set_debug_headers
  before_action only: [:create, :update] do 
    verify_type 'profiles'
  end
  
  # GET /api/v1/profiles.json
  scopes :index, 'scopes.profiles', 'scopes.profiles.readonly', 'scopes.admin'
  def index
    @profiles = MasterData::Profile.where(filter_params).includes(include_params).paginate(page_params)
    render json: @profiles, fields: serializer_fields, include: include_params
  end

  # GET /api/v1/profiles/1.json
  scopes :show, 'scopes.profiles.basic.readwrite', 'scopes.profiles.basic.readonly', 'scopes.profiles.civility.readwrite', 'scopes.profiles.civility.readonly', 'scopes.admin'
  def show
    render json: @profile, fields: serializer_fields, include: include_params
  end

  # POST /api/v1/profiles.json
  scopes :create, 'scopes.admin'
  def create
    @profile = MasterData::Profile.new(profile_params)

    if @profile.save
      render status: :created, json: @profile, fields: serializer_fields, include: include_params
    else
      render json: @profile.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/profiles/1.json
  scopes :update, 'scopes.profiles.basic.readwrite', 'scopes.profiles.civility.readwrite', 'scopes.admin'
  def update
      if @profile.update(profile_params)
        render status: :ok, json: @profile, fields: serializer_fields, include: include_params
      else
        render json: @profile.errors, status: :unprocessable_entity
      end
  end

  # DELETE /api/v1/profiles/1.json
  scopes :destroy, 'scopes.admin'
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
      params.require(:data).require(:attributes).permit(*authorized_write_fields)
    end

end


