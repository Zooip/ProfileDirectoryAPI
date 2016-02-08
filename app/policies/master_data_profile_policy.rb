class MasterData::ProfilePolicy < ApplicationPolicy
  def show?
    @record == @user.profile
  end

  def create? 
    true
  end

  def update? 
    record.user == user
  end

  def destroy?
    record.user == user
  end
end