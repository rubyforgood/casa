# frozen_string_literal: true

# Helper methods for new/edit contact type form
module ContactTypesHelper
  def set_group_options
    @group_options = ContactTypeGroup.for_organization(current_organization).collect { |group| [group.name, group.id] }
  end

  def time_ago_of_last_contact_made_of(contact_type_name, casa_case)
    contact = last_contact_made_of(contact_type_name, casa_case)

    return "never" if contact.nil?

    "#{time_ago_in_words(contact.occurred_at)} ago"
  end

  def last_contact_made_of(contact_type_name, casa_case)
    return unless casa_case

    casa_case
      .case_contacts
      .joins(:contact_types)
      .where(contact_types: {name: contact_type_name})
      .order(occurred_at: :desc)
      .first
  end
end
