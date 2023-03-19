# frozen_string_literal: true

class NotifcationComponent < ViewComponent::Base
  def initialize(notification:)
    @notification = notification
  end
end
