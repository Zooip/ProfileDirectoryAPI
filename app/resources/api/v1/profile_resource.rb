class Api::V1::ProfileResource < JSONAPI::Resource
  model_name 'MasterData::Profile'
  model_hint model: MasterData::Profile

  attributes :soce_id, :email, :first_name, :last_name, :full_name, :gender, :birth_date, :encrypted_password, :password
  attributes :connection_aliases

  has_many :oauth_applications, class_name:'OauthApplication'
  has_many :phone_numbers

  # Defines readable and writable attributes for each scopes.
  # Returns an hash asssociating scopes names with read/wrtie acess
  #
  # Exemple:
  #   {
  #     'scopes.profile.public.readonly' => {
  #       read: [:id, :first_name, :last_name, :full_name, :gender],
  #     },
  #     'scopes.profile.phones.readwrite' => {
  #       read: [:phones],
  #       write: [:phones],
  #     },
  #   }
  #
  # Use :_all_fields as an alias for all declared attributes
  #
  # TODO
  # For now public attributes are hard coded. Would be better to allow User to
  # customize which attributes are public for them.
  #
  # TODO
  # Public scope 'scopes.profile.public.readonly' is hard coded in
  # "allowed_fields_filter". Default scopes should be configurable
  #
  # TODO
  # Admin scope 'scopes.admin' is hard coded in "allowed_fields_filter".
  # Admin scopes should be configurable
  #
  def self.scopes_directory
  {
    'scopes.profile.public.readonly' => {
      read: [:id,:email, :first_name, :last_name, :full_name, :gender],
    },
    'scopes.profile.phones.readonly' => {
      read: [:phone_numbers],
    },
    'scopes.profile.phones.readwrite' => {
      read: [:phone_numbers],
      write: [:phone_numbers],
    },
    'scopes.profile.birth_date.readonly' => {
      read: [:birth_date],
      write: [],
    },
    'scopes.profiles.create' => {
      apply_on: :collection,
      write: [:_all_fields]
    }
  }
  end

  ## Computed attributes ##############

  #Returns person's fullname for clients convenience
  def full_name
    "#{@model.first_name} #{@model.last_name}"
  end

  #Returns connection_aliases as an Array instead as an association resource
  def connection_aliases
    @model.connection_aliases.pluck(:connection_alias)
  end

  #Update connection_aliases association from an Array
  def connection_aliases= array #TODO
  end

  # Attributes access rules ##########

  # Defines fields readable by clients
  # Write-only attributes are defined here
  # Use allowed_fields_filter to define access authorization
  def fetchable_fields
    allowed_read_fields_filter(super) - [:encrypted_password, :password]
  end

  # Defines fields updatables by clients
  # Read-only attributes are defined here
  # Use allowed_fields_filter to define access authorization
  def self.updatable_fields(context)
    allowed_fields_filter(:write, super,context)- [:full_name, :id, :uuid]
  end

  # Defines fields updatables by clients at creation
  # Read-only attributes are defined here
  # Use allowed_fields_filter to define access authorization
  def self.creatable_fields(context)
    allowed_fields_filter(:write, super,context) - [:full_name, :id, :uuid]
  end

  # Convenience instance method aliasing class method allowed_fields_filter
  def allowed_read_fields_filter _fields
    self.class.allowed_fields_filter(:read,_fields,context, @model)
  end


  # Filter input fields based on access type and context
  # Params:
  # access::   :read or :write
  # _fields::  Input fields to filter
  # context::  Controller context.
  #            Expect an hash containing keys [:current_oauth_scopes, :current_user]
  # resource:: Requested resource
  #
  # Public fields are defined here
  # Admin scope is defined here
  #
  # TODO
  # Find a way to pass @model for updatable and creatable fields
  def self.allowed_fields_filter(access,_fields,context={},resource= @model)
    # Check if the client has an admin scope
    if context[:current_oauth_scopes] && context[:current_oauth_scopes].include?('scopes.admin')
      #Allow all
      _fields
    else
      #Public fields are always allowed
      allowed_fields=scopes_directory['scopes.profile.public.readonly'][access].to_a

      #Checks resource_owner rights over this resource
      scopes_directory.values_at(*context[:current_oauth_scopes]).compact.each do |h|
        if ((h[:apply_on] == :collection) or (context[:current_user] && context[:current_user].profile == resource))
          allowed_fields+=h[access].to_a.compact 
        end
      end
      #Filter
      allowed_fields.include?(:_all_fields) ? _fields : _fields & allowed_fields
    end
  end

end
