class UserPolicy
  include PolicyHelper
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      case user.role
      when 'casa_admin' # scope.in_casa_administered_by(user)
        scope.all
      when 'volunteer'
        scope.where(id: user.id)
      else
        raise 'unrecognized role'
      end
    end
  end

  # TODO: Uncomment and test the below as necessary, please.

  # def index?
  #   casa_admin_of_org?(user, record)
  # end

  # def show?
  #   casa_admin_of_org?(user, record)
  # end

  # def create?
  #   casa_admin_of_org?(user, record)
  # end

  # def new?
  #   casa_admin_of_org?(user, record)
  # end

  # def update?
  #   casa_admin_of_org?(user, record)
  # end

  # def edit?
  #   casa_admin_of_org?(user, record)
  # end

  # def destroy?
  #   casa_admin_of_org?(user, record)
  # end
end
