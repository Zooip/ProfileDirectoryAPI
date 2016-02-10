class Api::V1::ProfilesController < Api::V1::BaseController
  include Oauthable

  before_action :set_debug_headers

  
  # GET /api/v1/profiles.json
  scopes :index, 'scopes.profiles.list.readonly'

  # GET /api/v1/profiles/1.json
  scopes :show, 'scopes.profile.public.readonly','scopes.profiles.basic.readwrite', 'scopes.profiles.basic.readonly', 'scopes.profiles.civility.readwrite', 'scopes.profiles.civility.readonly', 'scopes.profile.birth_date.readonly'

  # POST /api/v1/profiles.json
  scopes :create, 'scopes.profiles.create'

  # PATCH/PUT /api/v1/profiles/1.json
  scopes :update, 'scopes.profiles.basic.readwrite', 'scopes.profiles.civility.readwrite', 'scopes.profile.birth_date.readonly'

  # DELETE /api/v1/profiles/1.json
  scopes :destroy, 'scopes.profiles.delete'

end