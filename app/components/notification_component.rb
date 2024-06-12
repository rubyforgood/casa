# frozen_string_literal: true

class NotificationComponent < ViewComponent::Base
  attr_reader :notification

  def initialize(notification:)
    @notification = notification
  end

  def muted_display
    "bg-light text-muted" if notification.read?
  end
end
