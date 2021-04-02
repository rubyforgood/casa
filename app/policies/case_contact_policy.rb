class CaseContactPolicy < ApplicationPolicy
  def is_creator_or_casa_admin?
    is_admin? || is_creator?
  end

  def is_creator_or_supervisor_or_casa_admin?
    is_creator? || admin_or_supervisor?
  end

  alias_method :index?, :admin_or_supervisor_or_volunteer?
  alias_method :new?, :admin_or_supervisor_or_volunteer?
  alias_method :show?, :is_creator_or_casa_admin?
  alias_method :create?, :is_creator_or_casa_admin?
  alias_method :destroy?, :is_creator_or_casa_admin?
  alias_method :update?, :is_creator_or_supervisor_or_casa_admin?
  alias_method :edit?, :is_creator_or_supervisor_or_casa_admin?
  alias_method :restore?, :is_admin?

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      case @user
      when CasaAdmin, Supervisor # scope.in_casa_administered_by(@user)
        scope.all
      when Volunteer
        scope.where(casa_case: CasaCase.actively_assigned_to(@user), creator: @user)
      else
        raise "unrecognized user type #{@user.type}"
      end
    end
  end

  private

  def is_creator?
    record.creator == user
  end
end
