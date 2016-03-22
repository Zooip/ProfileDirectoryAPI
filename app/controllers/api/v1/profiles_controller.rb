class Api::V1::ProfilesController < Api::V1::BaseController
  include Oauthable

  def requested_resource
    params[:id] && MasterData::Profile.find(params[:id])
  end

  before_action :set_debug_headers
  
  # GET /api/v1/profiles.json
  scopes :index, 'scopes.profiles.list.readonly'

  # GET /api/v1/profiles/1.json
  scopes :show, 'scopes.profile.public.readonly','scopes.profile.birth_date.readonly','scopes.profile.phones.readonly'

  # POST /api/v1/profiles.json
  scopes :create, 'scopes.profiles.create'

  # PATCH/PUT /api/v1/profiles/1.json
  scopes :update, 'scopes.profile.basic.readwrite', 'scopes.profiles.civility.readwrite', 'scopes.profile.birth_date.readonly'

  # DELETE /api/v1/profiles/1.json
  scopes :destroy, 'scopes.profiles.delete'

  scopes :get_related_resource, 'scopes.oauth_apps.manage', 'scopes.oauth_apps.public.readonly', 'scopes.profiles.oauth_apps.readonly', 'scopes.profiles.oauth_apps.readwrite'
end