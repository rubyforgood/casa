class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications.newest_first
    @patch_notes = PatchNote.notes_available_for_user(current_user)
  end
end
