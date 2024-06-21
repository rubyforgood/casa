class NotificationsController < ApplicationController
  after_action :verify_authorized
  before_action :set_notification, only: %i[mark_as_read]

  def index
    authorize Noticed::Notification, policy_class: NotificationPolicy

    @deploy_time = Health.instance.latest_deploy_time
    @notifications = current_user.notifications.includes([:event]).newest_first
    @patch_notes = PatchNote.notes_available_for_user(current_user)
  end

  def mark_as_read
    authorize @notification, policy_class: NotificationPolicy

    @notification.mark_as_read unless @notification.read?
    redirect_to @notification.event.url
  end

  private

  def set_notification
    @notification = Noticed::Notification.find(params[:id])
  end
end
