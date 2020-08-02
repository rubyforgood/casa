class UserParameters < SimpleDelegator
  def initialize(params, key = :user)
    params =
      params.require(key).permit( # TODO BUG - admin create volunteer is broken
        :email,
        :casa_org_id,
        :display_name,
        :password,
        :active,
        :type
      )

    super(params)
  end

  def with_password(password)
    params[:password] = password
    self
  end

  def with_type(type)
    params[:type] = type
    self
  end

  def without_type
    params.delete(:type)
    self
  end

  def without_active
    params.delete(:active)
    self
  end

  private

  def params
    __getobj__
  end
end
