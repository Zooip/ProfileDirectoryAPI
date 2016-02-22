class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
    @oauth_scopes = user.scopes
    @user_mockup = user && user.resource_owner_id && UserMockup.find(user.resource_owner_id)
    @profile = @user_mockup && @user_mockup.profile
    @oauth_app = user.application
  end

  def index?
    false
  end

  def show?
    scope.where(:id => record.id).exists?
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end

  def scope
    Pundit.policy_scope!(user, record.class)
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
      scope
    end
  end
end
