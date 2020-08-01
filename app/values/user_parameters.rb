class UserParameters < SimpleDelegator
  def initialize(params, key = :user)
    params =
      params.require(key).permit(
        :email,
        :casa_org_id,
        :display_name,
        :password,
        :role
      )

    super(params)
  end

  def with_password(password)
    params[:password] = password
    self
  end

  def with_role(role)
    params[:role] = role
    self
  end

  def without_role
    params.delete(:role)
    self
  end

  private

  def params
    __getobj__
  end
end
