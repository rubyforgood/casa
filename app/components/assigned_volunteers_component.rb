class AssignedVolunteersComponent < ViewComponent::Base
  def initialize(casa_case, current_user)
    @casa_case = casa_case
    @current_user = current_user
  end
end
