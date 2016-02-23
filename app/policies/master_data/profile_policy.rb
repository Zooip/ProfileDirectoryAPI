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
end