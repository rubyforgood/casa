class UserParameters < SimpleDelegator
  def initialize(params, key = :user)
    params =
      params.require(key).permit(
        :email,
        :casa_org_id,
        :display_name,
        :phone_number,
        :password,
        :active,
        :receive_reimbursement_email,
        :type,
        :monthly_learning_hours_report,
        address_attributes: [:id, :content]
      )

    super(params)
  end

  def with_organization(organization)
    params[:casa_org_id] = organization.id
    self
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

  def with_only(*)
    params.slice!(*)
    self
  end

  def without(*keys)
    params.reject! { |key| keys.include?(key) }
  end

  private

  def params
    __getobj__
  end
end
