# frozen_string_literal: true

class NotificationComponent < ViewComponent::Base
  attr_reader :notification

  def initialize(notification:)
    @notification = notification
  end
end
