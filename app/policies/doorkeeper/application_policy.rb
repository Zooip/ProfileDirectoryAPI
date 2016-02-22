class Doorkeeper::ApplicationPolicy < ApplicationPolicy
 
  def show?
    return true if @oauth_scopes && @oauth_scopes.include?('scopes.admin')

    if @oauth_scopes && @oauth_scopes.include?('scopes.oauth_apps.public.readonly')
      return @record.is_public
    end

    if @oauth_scopes && @oauth_scopes.include?('scopes.oauth_apps.manage')
      return true
    end

    return false
  end

  def create?
    return true if @oauth_scopes && @oauth_scopes.include?('scopes.admin')
    return true if @oauth_scopes && @oauth_scopes.include?('scopes.oauth_apps.manage')
    if @oauth_scopes && @oauth_scopes.include?('scopes.profiles.oauth_apps.readwrite')
      return true if @profile.id == record.owner_id && record.owner_type = :profile
    end
    return false
  end

  def update? 
    return true if @oauth_scopes && @oauth_scopes.include?('scopes.admin')

    record.user == user
  end

  def destroy?
    return true if @oauth_scopes && @oauth_scopes.include?('scopes.admin')

    record.user == user
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
      return scope.where(is_public: true)
    end
  end

end
