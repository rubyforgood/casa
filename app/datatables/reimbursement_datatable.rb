class ReimbursementDatatable < ApplicationDatatable
  ORDERABLE_FIELDS = %w[
    display_name
    case_number
    occurred_at
    miles_driven
  ].freeze

  private

  def data
    records.map do |case_contact|
      {
        casa_case: {
          id: case_contact.casa_case.id,
          case_number: case_contact.casa_case.case_number
        },
        complete: case_contact.reimbursement_complete,
        contact_types: case_contact_types(case_contact),
        id: case_contact.id,
        mark_as_complete_path: mark_as_complete_path(case_contact),
        miles_driven: case_contact.miles_driven,
        occurred_at: case_contact.occurred_at,
        volunteer: {
          address: case_contact.creator.address&.content,
          display_name: case_contact.creator.display_name,
          email: case_contact.creator.email,
          id: case_contact.creator.id
        }
      }
    end
  end

  def case_contact_types(case_contact)
    case_contact.contact_types.map do |contact_type|
      {
        name: contact_type.name,
        group_name: contact_type.contact_type_group.name
      }
    end
  end

  def mark_as_complete_path(case_contact)
    "/reimbursements/#{case_contact.id}/mark_as_complete"
  end

  def raw_records
    base_relation
      .order(order_clause)
      .select(
        <<-SQL
          case_contacts.*,
          users.display_name AS volunteer
        SQL
      )
      .joins(:creator)
  end

  def order_clause
    @order_clause ||= build_order_clause
  end
end
