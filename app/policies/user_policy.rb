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
      when "casa_admin" # scope.in_casa_administered_by(user)
        scope.all
      when "volunteer"
        scope.where(id: user.id)
      when "supervisor"
        scope.all
      else
        raise "unrecognized role #{@user.role}"
      end
    end
  end
end
