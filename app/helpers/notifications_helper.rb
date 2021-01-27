module NotificationsHelper
  def notification_row_class(notification)
    return "" if notification.unread?
    " bg-light text-muted "
  end

  def notification_icon(notification)
    return "" if notification.read?
    "<i class='fas fa-bell'></i>".html_safe
  end
end
