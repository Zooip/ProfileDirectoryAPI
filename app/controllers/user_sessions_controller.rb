class UserSessionsController < ApiEngineBaseController

  
  # GET /login
  #Authentification forms
  def new
    @user_session = UserSession.new
    @redirect_url=redirect_params
  end

  # POST /login
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      if redirect_params.present?
        redirect_to redirect_params
      else
        redirect_to home_home_path
      end
    else
      render :action => :new
    end
  end

  # GET /logout
  # DELETE /logout
  def destroy
    current_user_session.destroy
    redirect_to root_path
  end


  private
  
    # Filter-out absolute URL. Only accept relative paths
    def redirect_params
      redirect_regex = /\A(?!http(s)?:\/\/).+/.match(params.fetch(:redirect,nil)).to_s
    end
end