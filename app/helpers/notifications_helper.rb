module NotificationsHelper
  def notifications_after_and_including_deploy(notifications)
    notifications.where(created_at: Health.instance.latest_deploy_time..)
  end

  def notifications_before_deploy(notifications)
    notifications.where(created_at: ...Health.instance.latest_deploy_time)
  end

  def notification_icon(notification)
    return "" if notification.read?
    "<i class='fas fa-bell'></i>".html_safe
  end

  def notification_row_class(notification)
    return "" if notification.unread?
    " bg-light text-muted "
  end
end
