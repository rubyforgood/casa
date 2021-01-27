class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications.newest_first
  end
end
