require "action_view"
require "action_view/helpers"

class ContactTypeDecorator < Draper::Decorator
  include ActionView::Helpers::DateHelper

  delegate_all

  def time_difference_since_most_recent_contact(casa_case)
    contact = last_contact_made_of(object.name, casa_case)

    return nil if contact.nil?

    "#{time_ago_in_words(contact.created_at)} ago"
  end

  def last_contact_made_of(contact_type_name, casa_case)
    return unless casa_case

    casa_case
      .case_contacts
      .joins(:contact_types)
      .where(contact_types: {name: contact_type_name})
      .order(created_at: :desc)
      .first
  end
end
