class NotificationsController < ApplicationController
  def index
    @deploy_time = Health.instance.latest_deploy_time
    @notifications = fetch_notifications_for_user(current_user)
    @patch_notes = PatchNote.notes_available_for_user(current_user)
  end

  private

  def fetch_notifications_for_user(user)
    Noticed::Notification.where(recipient: user).newest_first.includes(:event)
  end
end
