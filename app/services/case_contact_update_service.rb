class CaseContactUpdateService
  attr_reader :case_contact

  def initialize(case_contact)
    @case_contact = case_contact
  end

  def update_attrs(new_attrs)
    old_attrs = case_contact.as_json

    result = case_contact.update(new_attrs)
    update_status_metadata(old_attrs, new_attrs) if result

    result
  end

  private

  def update_status_metadata(old_attrs, new_attrs)
    return if old_attrs[:status] == new_attrs[:status]

    metadata = case_contact.metadata
    metadata["status"] ||= {}
    metadata["status"][new_attrs[:status]] = Time.zone.now

    case_contact.update(metadata: metadata)
  end
end
