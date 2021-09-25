class SupervisorDatatable < ApplicationDatatable
  ORDERABLE_FIELDS = %w[
    active
    display_name
    email
  ]

  private

  def data
    records.map do |supervisor|
      {
        id: supervisor.id,
        active: supervisor.active?,
        display_name: supervisor.display_name,
        email: supervisor.email,
        volunteer_assignments: supervisor.volunteers.count,
        transitions_volunteers: supervisor.volunteers_serving_transition_aged_youth,
        no_attempt_for_two_weeks: supervisor.no_attempt_for_two_weeks
      }
    end
  end

  def raw_records
    base_relation.order(order_clause, :id)
  end

  def filtered_records
    raw_records.where(active_filter)
  end

  def active_filter
    @active_filter ||=
      lambda do
        filter = additional_filters[:active]

        bool_filter filter do
          ["users.active = ?", filter[0]]
        end
      end.call
  end

  def order_clause
    @order_clause ||=
      build_order_clause || Arel.sql("COALESCE(users.display_name, users.email) #{order_direction}")
  end
end
