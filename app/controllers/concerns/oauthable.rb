module Oauthable
  extend ActiveSupport::Concern

  # Concerns class methods have to be included to be used outside controller methods
  included do

    # Check access_token and verify needed scopes if defined
    # If no scope is defined for an action, it only checks access_token validity
    #
    ## Note
    # Doorkeeper authorization MUST be placed in a before_action since it doesn't
    # raise an error but only use a render
    # Using it inside a Controler action may cause double render error
    before_action do
      _scopes=scopes_for(requested_action)
      _scopes.presence ? doorkeeper_authorize!(*_scopes) : doorkeeper_authorize!
    end

    private 

      # Defines wich scope to use as admin scope
      #
      ## TODO
      # Should not be hard-coded to avoid inconsistency with JSONAPI Ressources
      def self.admin_scope
        'scopes.admin'
      end

      # Defines scopes allowing to access an action
      # Automatically add admin scope
      #
      ## Exemple
      #
      #  scopes :show, 'scopes.profile.public.readonly','scopes.profiles.basic.readwrite'
      #  def show
      #     [....]
      #  end
      #
      def self.scopes action, *array
        oauth_scopes_directory[action.to_sym]=(array<<admin_scope).uniq
      end

      # Returns scopes allowing to access an action as an Array of Symbols
      def scopes_for action
        self.class.oauth_scopes_directory[action.to_sym].to_a
      end

      # Returns an Hash containings scopes allowing to access each actions
      def self.oauth_scopes_directory
        @oauth_scopes_directory ||= {}
      end    
  end

  # Returns action requested by client as a Symbol
  def requested_action
    params[:action].to_sym
  end

  # Returns the user that owns the access token
  # nil if no resource owner (ClientCredentials Flow)
  def current_user
    UserMockup.find(doorkeeper_token.resource_owner_id) if doorkeeper_token && doorkeeper_token.resource_owner_id
  end

  # Returns the scopes granted by current access token
  def current_oauth_scopes
    doorkeeper_token.scopes if doorkeeper_token
  end

  # Returns Doorkeeper::Application associated with current access token
  def current_oauth_application
    doorkeeper_token.application if doorkeeper_token
  end

  #Override Doorkeeper error for unauthorized error
  #
  ## TODO
  # Use a shared template for errors
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

  #Override Doorkeeper error for forbidden error
  #
  ## TODO
  # Use a shared template for errors
  def doorkeeper_forbidden_render_options(error: nil)
    { json: {
      errors:[
        { status: '403 Forbidden',
          code: 403,
          title: 'Invalid Scopes',
          detail: 'Your AccessToken\'s Scopes don\'t allow you to access this Ressource',
          meta:{
            allowed_scopes: error.instance_variable_get(:@scopes),
          }
         }]
      }
    }
  end

end