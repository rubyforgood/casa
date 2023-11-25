class LearningHourPolicy < ApplicationPolicy
  def index?
    admin_or_supervisor_or_volunteer?
  end

  def show?
    record.user_id == @user.id
  end

  def new?
    @user.volunteer?
  end

  alias_method :edit?, :show?
  alias_method :destroy?, :show?
  alias_method :create?, :show?
  alias_method :update?, :show?

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      case user
      when CasaAdmin
        scope.all_volunteers_learning_hours
      when Supervisor
        scope.supervisor_volunteers_learning_hours(@user.id)
      when Volunteer
        scope.where(user_id: @user.id)
      else
        raise "unrecognized role #{@user.type}"
      end
    end

    alias_method :index?, :resolve
  end
end
