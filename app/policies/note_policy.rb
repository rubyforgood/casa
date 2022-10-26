class NotePolicy < ApplicationPolicy
  def create?
    admin_or_supervisor?
  end

  def edit?
    create?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end
end
