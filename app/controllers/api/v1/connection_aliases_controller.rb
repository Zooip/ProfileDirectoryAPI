class Api::V1::ConnectionAliasesController < Api::V1::BaseController
  include Oauthable
  
  before_action :set_profile
  before_action :set_connection_alias, only: [:show, :update, :destroy]
  before_action :set_debug_headers


  # GET /master_data/connection_aliases.json
  def index
    @connection_aliases = @profile.connection_aliases.where(filter_params).paginate(page_params)
    render json: @connection_aliases, fields: fields_params, include: include_params
  end


  # GET /master_data/connection_aliases/1.json
  def show
    render json: @connection_alias, fields: fields_params, include: include_params
  end

  # POST /master_data/connection_aliases.json
  def create
    @connection_alias = @profile.connection_aliases.new(master_data_connection_alias_params)

    respond_to do |format|
      if @connection_alias.save
        format.json { render :show, status: :created, location: api_v1_connection_alias_url(@connection_alias) }
      else
        format.json { render json: @connection_alias.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /master_data/connection_aliases/1
  # PATCH/PUT /master_data/connection_aliases/1.json
  def update
    respond_to do |format|
      if @connection_alias.update(master_data_connection_alias_params)
        format.json { render :show, status: :ok, location: api_v1_connection_alias_url(@connection_alias) }
      else
        format.json { render json: @connection_alias.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /master_data/connection_aliases/1
  # DELETE /master_data/connection_aliases/1.json
  def destroy
    @connection_alias.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_connection_alias
      @connection_alias = MasterData::ConnectionAlias.find(params[:id])
    end

    def set_profile
      @connection_alias = MasterData::Profile.find(params[:profile_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def master_data_connection_alias_params
      params.require(:connection_alias).permit(:soce_id, :first_name, :last_name, :birth_last_name, :gender, :email, :birth_date, :death_date, :login_validation_check, :description, :created_at, :updated_at, :encrypted_password)
    end
end


