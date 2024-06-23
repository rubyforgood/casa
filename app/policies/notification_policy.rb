class NotificationPolicy < ApplicationPolicy
  def index?
    admin_or_supervisor_or_volunteer?
  end

  def mark_as_read?
    record&.recipient == user
  end
end
