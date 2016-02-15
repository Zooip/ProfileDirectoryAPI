class Api::V1::BaseController < ApplicationController
  include Rails.application.routes.url_helpers
  include JSONAPI::ActsAsResourceController

  skip_before_action :verify_authenticity_token #Cause errors when updating in JSON
  
  ## TODO
  # Allow clients to chose if they want to display debug infos
  # Should be false by default
  before_action :set_debug_headers


  private

    # Add a custom header to tell ResponseTimer midleware to display execution time
    def set_debug_headers
      response.headers['X-Debug-Time'] = 'true'
    end

    # Defines context for JSONAPI Resources
    def context
      {
        current_resource: requested_resource, # This is a quick hack to enable use of attributes filtering on update in JSONAPI::Resource
        current_user: current_user,
        current_oauth_scopes: current_oauth_scopes,
        current_oauth_application: current_oauth_application,
      }
    end

    #Defines the resource requested by client
    #To be overrided
    #This is a quick hack to enable use of attributes filtering on update in JSONAPI::Resource
    #TODO
    def requested_resource
      nil
    end
end