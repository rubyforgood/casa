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
    latest_hearing_date = @casa_case.most_recent_past_court_date
    latest_hearing_date.nil? ? "___<LATEST HEARING DATE>____" : I18n.l(latest_hearing_date.date, format: :full, default: nil)
  end

  def case_orders(orders)
    orders.map do |case_order|
      {
        order: case_order.text,
        status: case_order.implementation_status&.humanize
      }
    end
  end

  def filtered_interviewees
    CaseContactContactType
      .joins(:contact_type, case_contact: :casa_case)
      .where("case_contacts.casa_case_id": @casa_case.id)
      .where("case_contacts.occurred_at": @date_range)
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
  # "Question 1" => {topic: "Question 1", details: "Details 1", answers: [
  #   {date: "12/02/20", medium: "Type A1, Type B1", value: "Answer 1"},
  #   {date: "12/03/20", medium: "Type A2, Type B2", value: "Answer 3"}
  # ]},
  # "Question 2" => {topic: "Question 2", details: "Details 2", answers: [
  #   {date: "12/02/20", medium: "Type A1, Type B1", value: "Answer 2"},
  #   {date: "12/04/20", medium: "Type A3, Type B3", value: "Answer 5"}
  # ]},
  # "Question 3" => {topic: "Question 3", details: "Details 3", answers: [
  #   {date: "12/03/20", medium: "Type A2, Type B2", value: "No Answer Provided"},
  #   {date: "12/04/20", medium: "Type A3, Type B3", value: "No Answer Provided"}
  # ]}
  # }
  def court_topics
    topics = ContactTopic
      .joins(contact_topic_answers: {case_contact: [:casa_case, :contact_types]}).distinct
      .where("casa_cases.id": @casa_case.id)
      .where("case_contacts.occurred_at": @date_range)
      .order(:occurred_at, :value)
      .select(:details, :question, :occurred_at, :value, :contact_made,
        "STRING_AGG(contact_types.name, ', ' ORDER BY contact_types.name) AS medium_types")
      .group(:details, :question, :occurred_at, :value, :contact_made)

    topics.each_with_object({}) do |topic, hash|
      hash[topic.question] ||= {
        answers: [],
        topic: topic.question,
        details: topic.details
      }

      formatted_date = CourtReportFormatContactDate.new(topic).format_long
      answer_value = topic.value.blank? ? "No Answer Provided" : topic.value
      answer = {
        date: formatted_date,
        medium: topic.medium_types,
        value: answer_value
      }

      hash[topic.question][:answers].push(answer)
    end
  end

  private

  def calculate_date_range(args)
    zone = args[:time_zone] ? ActiveSupport::TimeZone.new(args[:time_zone]) : Time.zone

    start_date = @casa_case.most_recent_past_court_date&.date&.in_time_zone(zone)
    start_date = zone.parse(args[:start_date]) if args[:start_date]&.present?

    end_date = args[:end_date]&.present? ? zone.parse(args[:end_date]) : nil

    start_date..end_date
  end
end
