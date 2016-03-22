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

  def updatable_fields
    []
  end

  def fetchable_fields
    []
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  def has_admin_scope?
    @oauth_scopes && @oauth_scopes.include?(admin_scope)
  end

  def admin_scope
    self.class.admin_scope
  end

  def self.admin_scope
    'scopes.admin'
  end

  def fetchable_fields
    (fields_for(@oauth_scopes.to_a)[:read].to_a + public_scopes_readable_fields).uniq
  end

  def updatable_fields
    fields_for(@oauth_scopes.to_a)[:write].to_a
  end

  def creatable_fields
    self.updatable_fields
  end

  protected

  # List accepted fields for each scopes
  # To be overwrite in children
  #
  # exemple :
  # {
  #   'scopes.profile.public.readonly' => {
  #     read: public_fields,
  #     is_public: true,
  #   },
  #   'scopes.profile.basic.readwrite' => {
  #     read: public_fields,
  #     write: public_fields,
  # }
  def scopes_directory
    {}
  end


  # Return authorized fields for the given set of scopes.
  # Return an hash with readable and writable fields 
  def fields_for scopes
    scopes.each_with_object({}) do |x,h| 
      h.merge!(scopes_directory[x].to_h) do |key, oldval, newval|
        (newval + oldval).uniq
      end
    end
  end

  def public_scopes_readable_fields
    scopes_directory.select{|k,v| v[:is_public]}.map{|k,v| v[:read]}.flatten.uniq
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

    def admin_scope
      ApplicationPolicy.admin_scope
    end

    def resolve
      scope
    end
  end
end
