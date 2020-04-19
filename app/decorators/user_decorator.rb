class UserDecorator < Draper::Decorator
  delegate_all

  def status
    return 'Inactive' if object.role == 'inactive'

    'Active'
  end
end
