class Doorkeeper::ApplicationPolicy < ApplicationPolicy
 
  def show?
    return true if has_admin_scope?
    if @oauth_scopes
      return true if @oauth_scopes.include?('scopes.oauth_apps.manage')
      return @record.is_public if @oauth_scopes.include?('scopes.oauth_apps.public.readonly')
      return true  if (@oauth_scopes.to_a & ['scopes.profiles.oauth_apps.readwrite','scopes.profiles.oauth_apps.readonly']).any? && (@profile == record.owner)
    end
    return false
  end

  def create?
    return true if has_admin_scope?
    if @oauth_scopes
      return true if @oauth_scopes.include?('scopes.oauth_apps.manage')
      return true  if @oauth_scopes.include?('scopes.profiles.oauth_apps.readwrite') && (@profile == record.owner)
    end
    return false
  end

  def update? 
    return true if has_admin_scope?
    if @oauth_scopes
      return true if @oauth_scopes.include?('scopes.oauth_apps.manage')
      return true  if @oauth_scopes.include?('scopes.profiles.oauth_apps.readwrite') && (@profile == record.owner)
    end
    return false
  end

  def destroy?
    return true if has_admin_scope?
    if @oauth_scopes
      return true if @oauth_scopes.include?('scopes.oauth_apps.manage')
      return true  if @oauth_scopes.include?('scopes.profiles.oauth_apps.readwrite') && (@profile == record.owner)
    end
    return false
  end

  def update_relationship?
    true
  end

  def destroy_relationship?
    true
  end

  protected

  def scopes_directory
    all_fields=[:name, :uid, :secret, :redirect_uri, :scopes, :created_at, :updated_at, :is_public, :owner]

    {
      admin_scope => {
        read: all_fields,
        write: all_fields,
        },
      'scopes.oauth_apps.manage' => {
        read: all_fields,
        write: all_fields,
        },
      'scopes.oauth_apps.public.readonly' => {
        read: all_fields - [:secret],
        },
      'scopes.profiles.oauth_apps.readonly' =>{
        read: all_fields - [:secret],
        },
      'scopes.profiles.oauth_apps.readwrite' =>{
        read: all_fields,
        write: all_fields,
        },
   }
  end

  class Scope < ApplicationPolicy::Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
      @oauth_scopes = user.scopes
      @user_mockup = user && user.resource_owner_id && UserMockup.find(user.resource_owner_id)
      @profile = @user_mockup && @user_mockup.profile
      @oauth_app = user.application
    end

    def resolve
      if @oauth_scopes

        conditions=[]

        if (@oauth_scopes.to_a & ['scopes.oauth_apps.manage',admin_scope]).any?
          conditions << "TRUE"
        end
        if (@oauth_scopes.to_a & ['scopes.profiles.oauth_apps.readonly','scopes.profiles.oauth_apps.readwrite']).any?
          conditions << {"owner_id = :owner_id AND owner_type = 'MasterData::Profile'" => {owner_id: @profile && @profile.id}}
        end
        if @oauth_scopes.include? 'scopes.oauth_apps.public.readonly'
          conditions << "is_public = TRUE"
        end
      end

      if conditions.any?
        sql_collection=conditions.each_with_object({conditions:[],params:{}}) do |x,result|
          if x.is_a?(Hash)
           result[:conditions] << "(#{x.first[0]})"
           result[:params]=result[:params].merge(x.first[1])
          else
            result[:conditions] << "(#{x})"
          end
        end

        return scope.where(sql_collection[:conditions].join(" OR "),sql_collection[:params])
      end

      return scope.where("FALSE")
    end
  end

end
