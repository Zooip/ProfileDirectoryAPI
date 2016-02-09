module Oauthable
  extend ActiveSupport::Concern

  included do
    before_action do
      _scopes=scopes_for(requested_action)
      _scopes.presence ? doorkeeper_authorize!(*_scopes) : doorkeeper_authorize!
    end

    private 

      def self.admin_scope
        'scopes.admin'
      end

      def self.scopes action, *array
        oauth_scopes_directory[action.to_sym]=(array<<admin_scope).uniq
      end

      def scopes_for action
        self.class.oauth_scopes_directory[action.to_sym].to_a
      end

      def self.oauth_scopes_directory
        @oauth_scopes_directory ||= {}
      end

      def self.scopes_attributes hash
        @scopes_to_attributes = self.scopes_to_attributes.merge( hash ){|k, old_v, new_v| old_v + new_v}
      end

      def self.scopes_to_attributes
        @scopes_to_attributes ||= {}
      end

    
  end

  def requested_action
    params[:action].to_sym
  end

  # Find the user that owns the access token
  def current_user
    UserMockup.find(doorkeeper_token.resource_owner_id) if doorkeeper_token && doorkeeper_token.resource_owner_id
  end

  # Get the scopes granted by current access token
  def current_oauth_scopes
    doorkeeper_token.scopes if doorkeeper_token
  end

  def current_oauth_application
    doorkeeper_token.application if doorkeeper_token
  end

  def doorkeeper_unauthorized_render_options(error: nil)
        { json: {
      errors:[
        { status: '401 Unauthorized',
          code: 401,
          title: 'No AccessToken provided',
          detail: 'This Ressource is protected with OAuth2 and require an AccesToken for authorisation',
          links:{
            authorisation_url: Rails.application.routes.url_helpers.oauth_authorization_url,
            token_url: Rails.application.routes.url_helpers.oauth_token_url
          }
         }]
      }
    }
  end

  def doorkeeper_forbidden_render_options(error: nil)
    { json: {
      errors:[
        { status: '403 Forbidden',
          code: 403,
          title: 'Invalid Scopes',
          detail: 'Your AccessToken\'s Scopes don\'t allow you to access this Ressource',
          meta:{
            allowed_scopes: (scopes_for requested_action)
          }
         }]
      }
    }
  end

end