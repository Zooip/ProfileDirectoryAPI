class Api::V1::ConnectionAliasesController < Api::V1::BaseController
  before_action :set_master_data_connection_alias, only: [:show, :update, :destroy]
  before_action :set_debug_headers


  # GET /master_data/connection_aliases.json
  def index
    @master_data_connection_aliases = MasterData::ConnectionAlias.where(filter_params).paginate(page_params)
    render json: @master_data_connection_aliases, fields: fields_params, include: include_params
  end


  # GET /master_data/connection_aliases/1.json
  def show
    render json: @master_data_connection_alias, fields: fields_params, include: include_params
  end

  # POST /master_data/connection_aliases.json
  def create
    @master_data_connection_alias = MasterData::ConnectionAlias.new(master_data_connection_alias_params)

    respond_to do |format|
      if @master_data_connection_alias.save
        format.json { render :show, status: :created, location: api_v1_connection_alias_url(@master_data_connection_alias) }
      else
        format.json { render json: @master_data_connection_alias.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /master_data/connection_aliases/1
  # PATCH/PUT /master_data/connection_aliases/1.json
  def update
    respond_to do |format|
      if @master_data_connection_alias.update(master_data_connection_alias_params)
        format.json { render :show, status: :ok, location: api_v1_connection_alias_url(@master_data_connection_alias) }
      else
        format.json { render json: @master_data_connection_alias.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /master_data/connection_aliases/1
  # DELETE /master_data/connection_aliases/1.json
  def destroy
    @master_data_connection_alias.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_master_data_connection_alias
      @master_data_connection_alias = MasterData::ConnectionAlias.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def master_data_connection_alias_params
      params.require(:connection_alias).permit(:soce_id, :first_name, :last_name, :birth_last_name, :gender, :email, :birth_date, :death_date, :login_validation_check, :description, :created_at, :updated_at, :encrypted_password)
    end
end


