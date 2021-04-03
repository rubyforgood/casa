class BasePresenter
  private

  def current_user
    @current_user ||= RequestStore.read(:current_user)
  end

  def current_organization
    @current_organization ||= RequestStore.read(:current_organization)
  end

  def policy_scope(scope)
    Pundit.policy_scope!(current_user, scope)
  end
end
