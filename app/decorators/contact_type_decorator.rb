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
    last_contact = CaseContact.joins(:contact_types).where(casa_case_id: casa_case_ids, contact_types: {id: object.id}).order(occurred_at: :desc).first

    last_contact.nil? ? "never" : "#{time_ago_in_words(last_contact.occurred_at)} ago"
  end
end
