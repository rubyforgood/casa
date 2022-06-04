class OtherDutyPolicy < UserPolicy
  def index?
    admin_or_supervisor?
  end
end
