# frozen_string_literal: true

class NotificationComponent < ViewComponent::Base
  attr_reader :notification, :event

  def initialize(notification:, event:)
    @notification = notification
    @event = event
  end
end
