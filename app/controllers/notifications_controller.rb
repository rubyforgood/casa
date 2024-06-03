class NotificationsController < ApplicationController
  def index
    @deploy_time = Health.instance.latest_deploy_time
    @notifications = Noticed::Notification.where(recipient: user).newest_first.includes(:event)
    @patch_notes = PatchNote.notes_available_for_user(current_user)
  end
end
