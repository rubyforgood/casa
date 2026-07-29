class ContactTypeDecorator < Draper::Decorator
  include ActionView::Helpers::DateHelper
  delegate_all

  def hash_for_multi_select_with_cases(casa_case_ids)
    if casa_case_ids.nil?
      casa_case_ids = []
    end

    {value: object.id, text: object.name, group: object.contact_type_group.name, subtext: last_time_used_with_cases(casa_case_ids)}
  end

  def last_time_used_with_cases(casa_case_ids)
    last_contact = last_contact_with_cases(casa_case_ids)

    last_contact&.occurred_at.blank? ? "never" : "#{time_ago_in_words(last_contact.occurred_at)} ago"
  end

  # Labeled recency hint for the contact-type checkboxes. Returns nil when this type has never
  # been logged for the case(s) so the form can omit the line rather than show a bare "never".
  def last_logged_hint_with_cases(casa_case_ids)
    last_contact = last_contact_with_cases(casa_case_ids)
    return if last_contact&.occurred_at.blank?

    "Last logged #{time_ago_in_words(last_contact.occurred_at)} ago"
  end

  private

  def last_contact_with_cases(casa_case_ids)
    CaseContact.joins(:contact_types)
      .where(casa_case_id: casa_case_ids, contact_types: {id: object.id})
      .order(occurred_at: :desc).first
  end
end
