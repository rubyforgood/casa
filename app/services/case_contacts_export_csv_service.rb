require "csv"

class CaseContactsExportCsvService
  attr_reader :case_contacts_scope, :filtered_columns

  def initialize(case_contacts_scope, filtered_columns)
    @filtered_columns = filtered_columns
    @case_contacts_scope = case_contacts_scope
  end

  def perform
    case_contacts = case_contacts_scope.preload({creator: :supervisor}, :contact_types, :casa_case, :contact_topic_answers)

    CSV.generate do |csv|
      csv << fixed_column_headers + court_topics.values

      if case_contacts.present?
        case_contacts.decorate.each do |case_contact|
          csv << fixed_column_values(case_contact) + court_topic_answers(case_contact)
        end
      end
    end
  end

  def fixed_column_values(case_contact)
    # Note: these header labels are for stakeholders and do not match the
    # Rails DB names in all cases, e.g. added_to_system_at header is case_contact.created_at
    mappings = {
      internal_contact_number: case_contact.id,
      duration_minutes: case_contact.report_duration_minutes,
      contact_types: case_contact.report_contact_types,
      contact_made: case_contact.report_contact_made,
      contact_medium: case_contact.medium_type,
      occurred_at: I18n.l(case_contact.occurred_at, format: :full, default: nil),
      added_to_system_at: case_contact.created_at,
      miles_driven: case_contact.miles_driven,
      wants_driving_reimbursement: case_contact.want_driving_reimbursement,
      casa_case_number: case_contact.casa_case&.case_number,
      creator_email: case_contact.creator&.email,
      creator_name: case_contact.creator&.display_name,
      supervisor_name: case_contact.creator&.supervisor&.display_name,
      case_contact_notes: case_contact.notes
    }

    mappings.slice(*filtered_columns).values
  end

  def fixed_column_headers
    filtered_columns.excluding(:court_topics).map(&:to_s).map(&:titleize)
  end

  def court_topic_answers(case_contact)
    return [] if court_topics_filtered?

    # index_by so we don't loop through answers multiple times
    answers_by_topic_id = case_contact.contact_topic_answers.index_by(&:contact_topic_id)

    # we have to map values for all topics so we 'skip' unanswered ones (with a blank cell)
    court_topics.keys.map { |topic_id| answers_by_topic_id[topic_id]&.value }
  end

  def court_topics
    return {} if court_topics_filtered?

    @court_topics ||= ContactTopic
      .with_answers_in(case_contacts_scope)
      .order(:id)
      .select(:id, :question)
      .distinct
      .to_h { |topic| [topic.id, topic.question] }
  end

  def court_topics_filtered?
    return @court_topics_filtered if defined? @court_topics_filtered
    @court_topics_filtered = filtered_columns.exclude?(:court_topics)
  end
end
