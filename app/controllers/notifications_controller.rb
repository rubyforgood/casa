class NotificationsController < ApplicationController
  def index
    @deploy_time = Health.instance.latest_deploy_time
    @notifications = current_user.notifications.includes([:event]).newest_first
    @patch_notes = PatchNote.notes_available_for_user(current_user)
  end

  def mark_as_read
    @notification = Noticed::Notification.find(params[:id])
    @notification.mark_as_read unless @notification.read?
    redirect_to @notification.event.url
  end
end
