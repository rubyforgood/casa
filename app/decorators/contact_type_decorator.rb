class ContactTypeDecorator < Draper::Decorator
  include ActionView::Helpers::DateHelper
  delegate_all

  # last_logged_at_by_type is the CaseContact.last_logged_at_by_contact_type lookup. Pass it when
  # rendering a list of contact types; without it every option runs its own recency query.
  def hash_for_multi_select_with_cases(casa_case_ids, last_logged_at_by_type = nil)
    casa_case_ids = [] if casa_case_ids.nil?

    {
      value: object.id,
      text: object.name,
      group: object.contact_type_group.name,
      # Same recency hint the checkbox form uses, so a type that has never been logged shows no
      # subtext instead of a bare "never" beside every option. `.to_s`, not the bare nil: the option
      # template substitutes this through TomSelect's escape(), which turns nil into the literal
      # string "null".
      subtext: last_logged_hint_with_cases(casa_case_ids, last_logged_at_by_type).to_s
    }
  end

  # Labeled recency hint. Returns nil when this type has never been logged for the case(s) so the
  # caller can omit the line rather than show a bare "never". Used by both the contact-type
  # checkboxes and the multi-select options -- they had diverged, which is how "never" survived on
  # casa_cases#edit after being removed elsewhere.
  def last_logged_hint_with_cases(casa_case_ids, last_logged_at_by_type = nil)
    occurred_at = if last_logged_at_by_type
      last_logged_at_by_type[object.id]
    else
      last_contact_with_cases(casa_case_ids)&.occurred_at
    end
    return if occurred_at.blank?

    "Last logged #{time_ago_in_words(occurred_at)} ago"
  end

  private

  def last_contact_with_cases(casa_case_ids)
    CaseContact.joins(:contact_types)
      .where(casa_case_id: casa_case_ids, contact_types: {id: object.id})
      .order(occurred_at: :desc).first
  end
end
