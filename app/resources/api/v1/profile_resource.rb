class Api::V1::ProfileResource < JSONAPI::Resource
  model_name 'MasterData::Profile'
  model_hint model: MasterData::Profile

  attributes :id, :soce_id,:email, :first_name, :last_name, :full_name, :gender, :birth_date, :encrypted_password, :password
  attributes :connection_aliases

  has_many :oauth_applications, class_name:'OauthApplication'


  def self.scopes_directory
  {
    'scopes.profile.public.readonly' => {
      read: [:id, :first_name, :last_name, :gender],
    },
    'scopes.profile.phones.readonly' => {
      read: [:phones],
    },
    'scopes.profile.phones.readwrite' => {
      read: [:phones],
      write: [:phones],
    },
    'scopes.profile.birth_date.readonly' => {
      read: [:birth_date],
      write: [],
    }
  }
  end

  def full_name
    "#{@model.first_name} #{@model.last_name}"
  end

  def self.updatable_fields(context)

    allowed_fields_filter(super,context, :write)- [:full_name, :id, :uuid]
  end

  def self.creatable_fields(context)
    allowed_fields_filter(super,context, :write) - [:full_name, :id, :uuid]
  end


  def connection_aliases
    @model.connection_aliases.pluck(:connection_alias)
  end

  def fetchable_fields
    allowed_read_fields_filter(super) - [:encrypted_password, :password]
  end

  def allowed_read_fields_filter _fields
    self.class.allowed_fields_filter(_fields,context, @model, :read)
  end


  def self.allowed_fields_filter(_fields,context={},resource= @model, access = :read)
    if context[:current_oauth_scopes].include?('scopes.admin')
      _fields
    else
      allowed_fields=scopes_directory['scopes.profile.public.readonly'][access]
      if context[:current_user].profile == resource
        allowed_fields+=scopes_directory.values_at(*context[:current_oauth_scopes]).compact.map{|v| v[access]}.flatten
      end
      _fields & allowed_fields
    end
  end

end
