# frozen_string_literal: true

class NotificationComponent < ViewComponent::Base
  def initialize(notification:)
    @notification = notification
  end
end
