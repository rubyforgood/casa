class CaseContactMetadataCallback
  def after_commit(case_contact)
    changes = case_contact.saved_changes

    set_status(changes, case_contact) if changes["id"]
    update_status(changes, case_contact) if changes["status"] && changes["id"].nil?
  end

  private

  def set_status(changes, case_contact)
    metadata = {"status" => {case_contact.status => case_contact.created_at}}
    update_metadata(case_contact, metadata)
  end

  def update_status(changes, case_contact)
    metadata = {"status" => {changes["status"].last => Time.zone.now}}
    update_metadata(case_contact, metadata)
  end

  def update_metadata(record, new_data)
    metadata = record.metadata.deep_merge(new_data)
    record.update_columns(metadata: metadata)
  end
end
