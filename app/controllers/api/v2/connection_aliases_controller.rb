class Api::V2::ConnectionAliasesController < Api::V2::BaseController
  before_action :set_gram_connection_alias, only: [:show, :update, :destroy]
  before_action :set_debug_headers


  # GET /gram/connection_aliases.json
  def index
    @gram_connection_aliases = Gram::ConnectionAlias.where(filter_params).paginate(page_params)
    render json: @gram_connection_aliases, fields: fields_params, include: include_params
  end


  # GET /gram/connection_aliases/1.json
  def show
    render json: @gram_connection_alias, fields: fields_params, include: include_params
  end

  # POST /gram/connection_aliases.json
  def create
    @gram_connection_alias = Gram::ConnectionAlias.new(gram_connection_alias_params)

    respond_to do |format|
      if @gram_connection_alias.save
        format.json { render :show, status: :created, location: api_v2_connection_alias_url(@gram_connection_alias) }
      else
        format.json { render json: @gram_connection_alias.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gram/connection_aliases/1
  # PATCH/PUT /gram/connection_aliases/1.json
  def update
    respond_to do |format|
      if @gram_connection_alias.update(gram_connection_alias_params)
        format.json { render :show, status: :ok, location: api_v2_connection_alias_url(@gram_connection_alias) }
      else
        format.json { render json: @gram_connection_alias.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gram/connection_aliases/1
  # DELETE /gram/connection_aliases/1.json
  def destroy
    @gram_connection_alias.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gram_connection_alias
      @gram_connection_alias = Gram::ConnectionAlias.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def gram_connection_alias_params
      params.require(:connection_alias).permit(:soce_id, :first_name, :last_name, :birth_last_name, :gender, :email, :birth_date, :death_date, :login_validation_check, :description, :created_at, :updated_at, :encrypted_password)
    end
end


