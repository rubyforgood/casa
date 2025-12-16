# frozen_string_literal: true

class CaseContactDatatable < ApplicationDatatable
  ORDERABLE_FIELDS = %w[
    occurred_at
    contact_made
    medium_type
    duration_minutes
  ].freeze

  private

  def data
    records.map do |case_contact|
      {
        id: case_contact.id,
        occurred_at: I18n.l(case_contact.occurred_at, format: :full, default: nil),
        casa_case: {
          id: case_contact.casa_case_id,
          case_number: case_contact.casa_case&.case_number
        },
        contact_types: case_contact.contact_types.map(&:name).join(", "),
        medium_type: case_contact.medium_type&.titleize,
        creator: {
          id: case_contact.creator_id,
          display_name: case_contact.creator&.display_name,
          email: case_contact.creator&.email,
          role: case_contact.creator&.role
        },
        contact_made: case_contact.contact_made,
        duration_minutes: case_contact.duration_minutes,
        contact_topics: case_contact.contact_topics.map(&:question).join(" | "),
        is_draft: !case_contact.active?,
        has_followup: case_contact.followups.requested.exists?
      }
    end
  end

  def filtered_records
    raw_records.where(search_filter)
  end

  def raw_records
    base_relation
      .joins("INNER JOIN users creators ON creators.id = case_contacts.creator_id")
      .left_joins(:casa_case)
      .includes(:contact_types, :contact_topics, :followups, :creator)
      .order(order_clause)
      .order(:id)
  end

  def search_filter
    return "TRUE" if search_term.blank?

    ilike_fields = %w[
      creators.display_name
      creators.email
      casa_cases.case_number
      case_contacts.notes
    ]

    ilike_clauses = ilike_fields.map { |field| "#{field} ILIKE ?" }.join(" OR ")
    contact_type_clause = "case_contacts.id IN (#{contact_type_search_subquery})"

    full_clause = "#{ilike_clauses} OR #{contact_type_clause}"
    [full_clause, ilike_fields.count.times.map { "%#{search_term}%" }].flatten
  end

  def contact_type_search_subquery
    @contact_type_search_subquery ||= lambda {
      return "SELECT NULL WHERE FALSE" if search_term.blank?

      CaseContact
        .select("DISTINCT case_contacts.id")
        .joins(case_contact_contact_types: :contact_type)
        .where("contact_types.name ILIKE ?", "%#{search_term}%")
        .to_sql
    }.call
  end

  def order_clause
    @order_clause ||= build_order_clause
  end
end
