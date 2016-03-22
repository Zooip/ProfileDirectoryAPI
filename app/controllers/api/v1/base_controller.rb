class Api::V1::BaseController < ApplicationController
  include Rails.application.routes.url_helpers
  include JSONAPI::ActsAsResourceController

  skip_before_action :verify_authenticity_token #Cause errors when updating in JSON
  
  ## TODO
  # Allow clients to chose if they want to display debug infos
  # Should be false by default
  before_action :set_debug_headers

 rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
 rescue_from ActiveRecord::RecordNotFound, with: :render_404_not_found

   private

  # https://github.com/cerebris/jsonapi-resources/pull/573
  def handle_exceptions(e)
    if JSONAPI.configuration.exception_class_whitelist.any? { |k| e.class.ancestors.include?(k) }
      raise e
    else
      super
    end
  end

  private
    def user_not_authorized
      render json: {
        errors:[
          { status: '403 Forbidden',
            code: 403,
            title: "Not allowed to access this ressource",
           }]
        }, status: :forbidden
    end

    # Add a custom header to tell ResponseTimer midleware to display execution time
    def set_debug_headers
      response.headers['X-Debug-Time'] = 'true'
    end

    # Defines context for JSONAPI Resources
    def context
      {
        current_resource: requested_resource, # This is a quick hack to enable use of attributes filtering on update in JSONAPI::Resource
        current_token: doorkeeper_token,
        current_user: current_user,
        current_oauth_scopes: current_oauth_scopes,
        current_oauth_application: current_oauth_application,
        controller: self,
        current_action: params[:action]
      }
    end

    #Defines the resource requested by client
    #To be overrided
    #This is a quick hack to enable use of attributes filtering on update in JSONAPI::Resource
    #TODO
    def requested_resource
      nil
    end

    def render_404_not_found (e)
      render json: {
      errors:[
        { status: '404 Not Found',
          code: 404,
          title: 'Resource not found',
          detail: 'Not able to find this resource with your current access token',
         }]
      }, status: :not_found
    end
end

