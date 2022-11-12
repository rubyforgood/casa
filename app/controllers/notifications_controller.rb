class NotificationsController < ApplicationController
  def index
    @deploy_time = Health.instance.latest_deploy_time
    @notifications = current_user.notifications.newest_first
    @patch_notes = {}

    PatchNote.notes_available_for_user(current_user).each do |patch_note|
      patch_note_type_name = patch_note.patch_note_type.name

      unless @patch_notes.has_key?(patch_note_type_name)
        @patch_notes[patch_note_type_name] = []
      end

      @patch_notes[patch_note_type_name].push(patch_note.note)
    end
  end
end
