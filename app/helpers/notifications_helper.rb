module NotificationsHelper
  def notifications_after_and_including_deploy(notifications)
    latest_deploy_time = Health.instance.latest_deploy_time

    if latest_deploy_time.nil?
      []
    else
      notifications.where(created_at: latest_deploy_time..)
    end
  end

  def notifications_before_deploy(notifications)
    notifications.where(created_at: ...Health.instance.latest_deploy_time)
  end

  def patch_notes_as_hash_keyed_by_type_name(patch_notes)
    patch_notes_hash = {}

    patch_notes.each do |patch_note|
      patch_note_type_name = patch_note.patch_note_type.name

      unless patch_notes_hash.has_key?(patch_note_type_name)
        patch_notes_hash[patch_note_type_name] = []
      end

      patch_notes_hash[patch_note_type_name].push(patch_note.note)
    end

    patch_notes_hash
  end
end
