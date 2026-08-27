# frozen_string_literal: true

require "date"

class CaseCourtReportContext
  attr_reader :report_path, :template, :date_range

  def initialize(args = {})
    @casa_case = CasaCase.friendly.find(args[:case_id])
    @volunteer = Volunteer.find(args[:volunteer_id]) if args[:volunteer_id]
    @time_zone = args[:time_zone]
    @path_to_template = args[:path_to_template]
    @court_date = args[:court_date] || @casa_case.next_court_date
    @case_court_orders = args[:case_court_orders] || @casa_case.case_court_orders
    @include_empty_topics = ActiveModel::Type::Boolean.new.cast(args[:include_empty_topics])
    @date_range = calculate_date_range(args)
  end

  def context
    {
      created_date: I18n.l(Time.current.in_time_zone(@time_zone).to_date, format: :full, default: nil),
      casa_case: case_details,
      case_contacts: case_contacts,
      case_court_orders: case_orders(@case_court_orders),
      case_mandates: case_orders(@case_court_orders), # backwards compatible with old Montgomery template - keep this! TODO test full generation
      latest_hearing_date: latest_hearing_date,
      org_address: org_address(@path_to_template),
      volunteer: volunteer_info,
      hearing_type_name: @court_date&.hearing_type&.name || "None",
      case_topics: court_topics.values
    }
  end

  # @return [Array<Hash>]
  #   Each hash includes:
  #   - :name [String]
  #   - :type [String]
  #   - :dates [Array<String>]
  #   - :dates_by_medium_type [Array<String>]
  def case_contacts
    interviewees = filtered_interviewees
    return [] unless interviewees.size.positive?

    CaseContactsContactDates.new(interviewees).contact_dates_details
  end

  def latest_hearing_date
    most_recent_past_court_date.nil? ? "___<LATEST HEARING DATE>____" : I18n.l(most_recent_past_court_date.date, format: :full, default: nil)
  end

  # CasaCase#most_recent_past_court_date is a scoped query on the court_dates association, so it
  # re-runs on every call. Both the date range and the hearing-date label need it, so resolve it
  # once per report.
  def most_recent_past_court_date
    return @most_recent_past_court_date if defined?(@most_recent_past_court_date)

    @most_recent_past_court_date = @casa_case.most_recent_past_court_date
  end

  def case_orders(orders)
    orders.map do |case_order|
      {
        order: case_order.text,
        status: case_order.implementation_status&.humanize
      }
    end
  end

  # includes, not just joins: CaseContactsContactDates walks every row calling #contact_type and
  # #case_contact, so joining alone still costs two queries per interviewee row.
  def filtered_interviewees
    CaseContactContactType
      .joins(contact_type: :contact_type_group, case_contact: :casa_case)
      .includes(:case_contact, contact_type: :contact_type_group)
      .where("case_contacts.casa_case_id": @casa_case.id)
      .where("case_contacts.occurred_at": @date_range)
      .order("contact_type_groups.name ASC", "contact_types.name ASC", "case_contact_contact_types.id ASC")
  end

  def case_details
    {
      court_date: I18n.l(@court_date&.date, format: :full, default: nil),
      case_number: @casa_case.case_number,
      dob: I18n.l(@casa_case.birth_month_year_youth, format: :youth_date_of_birth, default: nil),
      is_transitioning: @casa_case.in_transition_age?,
      judge_name: @court_date&.judge&.name
    }
  end

  def volunteer_info
    if @volunteer
      {
        name: @volunteer.display_name,
        supervisor_name: @volunteer.supervisor&.display_name || "",
        assignment_date: I18n.l(@casa_case.case_assignments.find_by(volunteer: @volunteer).created_at, format: :full, default: nil)
      }
    end
  end

  def org_address(path_to_template)
    is_default_template = path_to_template.end_with?("default_report_template.docx")
    @volunteer.casa_org.address if @volunteer && is_default_template
  end

  # Sample output
  #
  # expected_topics = {
  # "Question 1" => {topic: "Question 1", details: "", answers: [
  #   {date: "12/02/20", medium: "Type A1, Type B1", value: "Answer 1"},
  #   {date: "12/03/20", medium: "Type A2, Type B2", value: "Answer 3"}
  # ]},
  # "Question 2" => {topic: "Question 2", details: "", answers: [
  #   {date: "12/02/20", medium: "Type A1, Type B1", value: "Answer 2"},
  #   {date: "12/04/20", medium: "Type A3, Type B3", value: "Answer 5"}
  # ]},
  # "Question 3" => {topic: "Question 3", details: "", answers: [
  #   {date: "12/03/20", medium: "Type A2, Type B2", value: "No Answer Provided"},
  #   {date: "12/04/20", medium: "Type A3, Type B3", value: "No Answer Provided"}
  # ]}
  # }
  def court_topics
    answers_by_topic_id = court_topic_answers

    report_topics(answers_by_topic_id.keys).each_with_object({}) do |topic, hash|
      hash[topic.question] = {
        answers: answers_by_topic_id.fetch(topic.id, []),
        topic: topic.question,
        details: ""
      }
    end
  end

  private

  def report_topics(answered_topic_ids)
    topics = ContactTopic
      .where(casa_org: @casa_case.casa_org, exclude_from_court_report: false)
      .order(:question)

    return topics.where(id: answered_topic_ids) unless @include_empty_topics

    topics.merge(ContactTopic.active.or(ContactTopic.where(id: answered_topic_ids)))
  end

  def court_topic_answers
    answer_rows = ContactTopic
      .joins(contact_topic_answers: {case_contact: [:casa_case, :contact_types]}).distinct
      .where("casa_cases.id": @casa_case.id)
      .where("case_contacts.occurred_at": @date_range)
      .order(:occurred_at, :value)
      .select("contact_topics.id", :occurred_at, :value, :contact_made,
        "STRING_AGG(contact_types.name, ', ' ORDER BY contact_types.name) AS medium_types")
      .group("contact_topics.id", :occurred_at, :value, :contact_made)

    answer_rows.group_by(&:id).transform_values do |rows|
      rows.map do |row|
        {
          date: CourtReportFormatContactDate.new(row).format_long,
          medium: row.medium_types,
          value: row.value.presence || "No Answer Provided"
        }
      end
    end
  end

  def calculate_date_range(args)
    zone = args[:time_zone] ? ActiveSupport::TimeZone.new(args[:time_zone]) : Time.zone

    start_date = most_recent_past_court_date&.date&.in_time_zone(zone)
    start_date = zone.parse(args[:start_date]) if args[:start_date]&.present?

    end_date = args[:end_date]&.present? ? zone.parse(args[:end_date]) : nil

    start_date..end_date
  end
end
