class MasterData::ProfilePolicy < ApplicationPolicy
  def show?
    record == @profile
  end

  def create?
    true
  end

  def update? 
    record == @profile
  end

  def destroy?
    record.user == @profile
  end
  
  def fetchable_fields
    super - [:encrypted_password, :password]
  end

  protected

  def scopes_directory
    all_fields=[:oauth_applications, :phone_numbers, :id, :soce_id, :email, :first_name, :last_name, :full_name, :gender, :birth_date, :encrypted_password, :password, :connection_aliases]
    public_fields=[:id,:email, :first_name, :last_name, :full_name, :gender]


    {
      'scopes.profile.public.readonly' => {
        read: public_fields,
        is_public: true,
      },
      'scopes.profile.basic.readwrite' => {
        read: public_fields,
        write: public_fields,
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
      'scopes.admin' => {
        read: all_fields,
        write: all_fields,
      },
      'scopes.profiles.create' => {
        apply_on: :collection,
        write: all_fields,
      },
      'scopes.profiles.list.readonly' => {
        apply_on: :collection,
        read: public_fields,
      },
    }
  end
end