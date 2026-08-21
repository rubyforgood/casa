class VolunteerDatatable < ApplicationDatatable
  ORDERABLE_FIELDS = %w[
    active
    contacts_made_in_past_days
    display_name
    email
    has_transition_aged_youth_cases
    most_recent_attempt_occurred_at
    supervisor_name
    hours_spent_in_days
  ]

  # Window for the "Hours (30 days)" column.
  HOURS_SPENT_IN_DAYS = 30

  # Server-side entry point for the migrated (bespoke Pagy) index. Reuses the same
  # filter/search/order SQL as the DataTables JSON path; the controller maps plain GET
  # params into the DataTables param shape. Preloads languages for the extra-languages column.
  def index_relation
    filtered_records.includes(:languages)
  end

  # Count for the migrated index's Pagy bar. filtered_records carries a custom SELECT
  # (COALESCE aliases) and an ORDER by one of those aliases, neither of which AR's COUNT
  # can wrap, so strip them and count distinct volunteers (distinct guards the
  # extra-languages join fan-out).
  def index_count
    index_relation.except(:select, :order, :includes).distinct.count("users.id")
  end

  private

  def data
    volunteers = records.to_a
    preload_languages(volunteers)
    active_case_counts = active_case_counts_for(volunteers)
    contacted_case_counts = contacted_case_counts_for(volunteers)
    minutes_spent = minutes_spent_for(volunteers)

    volunteers.map do |volunteer|
      {
        active: volunteer.active?,
        casa_cases: volunteer.casa_cases.map { |cc| {id: cc.id, case_number: cc.case_number} },
        contacts_made_in_past_days: volunteer.contacts_made_in_past_days,
        display_name: NamePresentation.strip_honorific(volunteer.display_name),
        email: volunteer.email,
        has_transition_aged_youth_cases: volunteer.has_transition_aged_youth_cases?,
        id: volunteer.id,
        made_contact_with_all_cases_in_days:
          made_contact_with_all_cases?(volunteer, active_case_counts, contacted_case_counts),
        most_recent_attempt: {
          case_id: volunteer.most_recent_attempt_case_id,
          occurred_at: I18n.l(volunteer.most_recent_attempt_occurred_at, format: :full, default: nil)
        },
        supervisor: {id: volunteer.supervisor_id, name: NamePresentation.strip_honorific(volunteer.supervisor_name)},
        hours_spent_in_days: Volunteer.format_hours_and_minutes(minutes_spent.fetch(volunteer.id, 0)),
        extra_languages: volunteer.languages&.map { |lang| {id: lang.id, name: lang.name} }
      }
    end
  end

  # Preloaded against the already-loaded page rather than via raw_records.includes(:languages):
  # filtered_records can carry SELECT aliases, DISTINCT and an ORDER BY on an alias (the
  # extra_languages filter), and an includes on that relation makes Rails build an id-lookup
  # query that repeats the alias in its own SELECT list, which Postgres rejects.
  def preload_languages(volunteers)
    ActiveRecord::Associations::Preloader.new(records: volunteers, associations: :languages).call
  end

  # Mirrors Volunteer#made_contact_with_all_cases_in_days? using the page-wide counts below.
  def made_contact_with_all_cases?(volunteer, active_case_counts, contacted_case_counts)
    active_cases = active_case_counts.fetch(volunteer.id, 0)
    return true if active_cases.zero?

    contacted_case_counts.fetch(volunteer.id, 0) == active_cases
  end

  # The three aggregates below mirror Volunteer#made_contact_with_all_cases_in_days? and
  # Volunteer#hours_spent_in_days, but each runs a single grouped query for the whole page
  # instead of two or three queries per row.
  def active_case_counts_for(volunteers)
    actively_assigned(volunteers).group(:volunteer_id).count
  end

  # NOTE: deliberately NOT distinct, to match Volunteer#cases_where_contact_made_in_days, which
  # counts contact rows rather than cases. That makes a volunteer with more contacts than active
  # cases look like they have not reached everyone -- pre-existing behaviour, preserved here so
  # this stays a performance change only.
  def contacted_case_counts_for(volunteers)
    actively_assigned(volunteers)
      .joins(casa_case: :case_contacts)
      .where(case_contacts: {contact_made: true, occurred_at: contact_made_cutoff..})
      .group(:volunteer_id)
      .count
  end

  def minutes_spent_for(volunteers)
    actively_assigned(volunteers)
      .joins(casa_case: :case_contacts)
      .where(case_contacts: {contact_made: true, occurred_at: HOURS_SPENT_IN_DAYS.days.ago.to_date..})
      .group(:volunteer_id)
      .sum(:duration_minutes)
  end

  # Volunteer#actively_assigned_and_active_cases, expressed from the assignment side so it can be
  # grouped by volunteer.
  def actively_assigned(volunteers)
    CaseAssignment
      .active
      .joins(:casa_case)
      .where(volunteer_id: volunteers.map(&:id), casa_cases: {active: true})
  end

  def contact_made_cutoff
    Volunteer::CONTACT_MADE_IN_DAYS_NUM.days.ago.to_date
  end

  def filtered_records
    extra_languages_filter do
      raw_records
        .where(supervisor_filter)
        .where(active_filter)
        .where(transition_aged_youth_filter)
        .where(search_filter)
    end
  end

  def raw_records
    base_relation
      .select(
        <<-SQL
          users.*,
          COALESCE(users.display_name, users.email) AS default_sort_order,
          COALESCE(supervisors.display_name, supervisors.email) AS supervisor_name,
          supervisors.id AS supervisor_id,
          transition_aged_youth_cases.volunteer_id IS NOT NULL AS has_transition_aged_youth_cases,
          most_recent_attempts.casa_case_id AS most_recent_attempt_case_id,
          most_recent_attempts.occurred_at AS most_recent_attempt_occurred_at,
          contacts_made_in_past_days.contact_count AS contacts_made_in_past_days,
          hours_spent_in_days.duration_minutes AS hours_spent_in_days
        SQL
      )
      .joins(
        <<-SQL
          LEFT JOIN supervisor_volunteers ON supervisor_volunteers.volunteer_id = users.id AND supervisor_volunteers.is_active
          LEFT JOIN users supervisors ON supervisors.id = supervisor_volunteers.supervisor_id AND supervisors.active
          LEFT JOIN (
            #{sanitize_sql(transition_aged_youth_cases_subquery)}
          ) transition_aged_youth_cases ON transition_aged_youth_cases.volunteer_id = users.id
          LEFT JOIN (
            #{sanitize_sql(most_recent_attempts_subquery)}
          ) most_recent_attempts ON most_recent_attempts.creator_id = users.id AND most_recent_attempts.contact_index = 1
          LEFT JOIN (
            #{sanitize_sql(contacts_made_in_past_days_subquery)}
          ) contacts_made_in_past_days ON contacts_made_in_past_days.creator_id = users.id
          LEFT JOIN (
            #{sanitize_sql(hours_spent_in_days_subquery)}
          ) hours_spent_in_days ON hours_spent_in_days.creator_id = users.id
        SQL
      )
      .order(order_clause)
      .order(:id)
      .includes(:casa_cases)
  end

  def transition_aged_youth_cases_subquery
    @transition_aged_youth_cases_subquery ||=
      CaseAssignment
        .select(:volunteer_id)
        .joins(:casa_case)
        .where(casa_cases: {birth_month_year_youth: ..CasaCase::TRANSITION_AGE.years.ago})
        .active
        .group(:volunteer_id)
        .to_sql
  end

  def most_recent_attempts_subquery
    @most_recent_attempts_subquery ||=
      CaseContact
        .select(
          <<-SQL
          *,
          ROW_NUMBER() OVER(PARTITION BY creator_id ORDER BY occurred_at DESC NULLS LAST) AS contact_index
          SQL
        )
        .to_sql
  end

  def contacts_made_in_past_days_subquery
    @contacts_made_in_past_days_subquery ||=
      CaseContact
        .select(
          <<-SQL
          creator_id,
          COUNT(*) AS contact_count
          SQL
        )
        .where(contact_made: true, occurred_at: Volunteer::CONTACT_MADE_IN_PAST_DAYS_NUM.days.ago.to_date..)
        .group(:creator_id)
        .to_sql
  end

  def hours_spent_in_days_subquery
    @hours_spent_in_days_subquery ||=
      CaseContact
        .select(
          <<-SQL
          creator_id,
          SUM(duration_minutes) AS duration_minutes
          SQL
        )
        .where(contact_made: true, occurred_at: 60.days.ago.to_date..)
        .group(:creator_id)
        .to_sql
  end

  def order_clause
    @order_clause ||= build_order_clause || Arel.sql("default_sort_order ASC")
  end

  def supervisor_filter
    @supervisor_filter ||=
      if (filter = additional_filters[:supervisor]).blank?
        "FALSE"
      elsif filter.all?(&:blank?)
        "supervisors.id IS NULL"
      else
        null_filter = "supervisors.id IS NULL OR" if filter.any?(&:blank?)
        ["#{null_filter} COALESCE(supervisors.id) IN (?)", filter.select(&:present?)]
      end
  end

  def active_filter
    @active_filter ||=
      lambda {
        filter = additional_filters[:active]

        bool_filter filter do
          ["users.active = ?", filter[0]]
        end
      }.call
  end

  def transition_aged_youth_filter
    @transition_aged_youth_filter ||=
      lambda {
        filter = additional_filters[:transition_aged_youth]

        bool_filter filter do
          "transition_aged_youth_cases.volunteer_id IS #{(filter[0] == "true") ? "NOT" : nil} NULL"
        end
      }.call
  end

  def extra_languages_filter
    filter = additional_filters[:extra_languages]
    return yield unless filter

    if filter.count > 1
      yield.includes(:languages).distinct
    elsif filter[0] == "true"
      yield.joins(:languages).distinct
    elsif filter[0] == "false"
      yield.includes(:languages).excluding(base_relation.joins(:languages)).distinct
    end
  end

  def search_filter
    @search_filter ||=
      lambda {
        return "TRUE" if search_term.blank?

        ilike_fields = %w[
          users.display_name
          users.email
          supervisors.display_name
          supervisors.email
        ]
        ilike_clauses = ilike_fields.map { |field| "#{field} ILIKE ?" }.join(" OR ")
        casa_case_number_clause = "users.id IN (#{casa_case_number_filter_subquery})"
        full_clause = "#{ilike_clauses} OR #{casa_case_number_clause}"

        [full_clause, ilike_fields.count.times.map { "%#{search_term}%" }].flatten
      }.call
  end

  def casa_case_number_filter_subquery
    @casa_case_number_filter_subquery ||=
      lambda {
        return "" if search_term.blank?

        CaseAssignment
          .select(:volunteer_id)
          .joins(:casa_case)
          .where("casa_cases.case_number ILIKE ? AND case_assignments.active = true", "%#{search_term}%")
          .group(:volunteer_id)
          .to_sql
      }.call
  end
end
