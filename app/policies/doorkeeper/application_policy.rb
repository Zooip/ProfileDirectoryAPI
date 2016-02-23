class Doorkeeper::ApplicationPolicy < ApplicationPolicy
 
  def show?

    if @oauth_scopes
      return true if @oauth_scopes.include?('scopes.admin')
      return true if @oauth_scopes.include?('scopes.oauth_apps.manage')
      return @record.is_public if @oauth_scopes.include?('scopes.oauth_apps.public.readonly')
      byebug
      return (@profile == record.owner) if (@oauth_scopes.to_a & ['scopes.oauth_apps.manage','scopes.admin']).any?
    end
    return false
  end

  def create?
    if @oauth_scopes
      return true if @oauth_scopes.include?('scopes.admin')
      return true if @oauth_scopes.include?('scopes.oauth_apps.manage')
      return (@profile == record.owner) if @oauth_scopes.include?('scopes.profiles.oauth_apps.readwrite')
    end
    return false
  end

  def update? 
    if @oauth_scopes
      return true if @oauth_scopes.include?('scopes.admin')
      return true if @oauth_scopes.include?('scopes.oauth_apps.manage')
      return (@profile == record.owner) if @oauth_scopes.include?('scopes.profiles.oauth_apps.readwrite')
    end
    return false
  end

  def destroy?
    if @oauth_scopes
      return true if @oauth_scopes.include?('scopes.admin')
      return true if @oauth_scopes.include?('scopes.oauth_apps.manage')
      return (@profile == record.owner) if @oauth_scopes.include?('scopes.profiles.oauth_apps.readwrite')
    end
    return false
  end

  class Scope
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
      if (@oauth_scopes && (@oauth_scopes.to_a & ['scopes.oauth_apps.manage','scopes.admin']).any?)
        return scope
      end
      if (@oauth_scopes && (@oauth_scopes.to_a & ['scopes.profiles.oauth_apps.readonly','scopes.profiles.oauth_apps.readwrite']).any?)
        return scope.where("is_public = TRUE OR (owner_id = :owner_id AND owner_type = 'MasterData::Profile')", {owner_id: @profile && @profile.id})
      end
      return scope.where("is_public = TRUE")
    end
  end

end
