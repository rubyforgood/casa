require "csv"

class CaseContactsExportCsvService
  attr_reader :case_contacts, :filtered_columns

  def initialize(case_contacts_scope, filtered_columns = nil)
    @filtered_columns = filtered_columns || CaseContactReport::COLUMNS
    @base_scope = case_contacts_scope

    @case_contacts = case_contacts_scope.preload({creator: :supervisor}, :contact_types, :casa_case)
  end

  def perform
    CSV.generate(headers: true) do |csv|
      filtered_columns.delete(:court_topics)
      csv << filtered_columns.map(&:to_s).map(&:titleize) + court_topics
      if case_contacts.present?
        case_contacts.decorate.each do |case_contact|
          csv << fixed_column_values(case_contact) + court_topic_answers(case_contact)
        end
      end
    end
  end

  def self.fixed_columns(case_contact)
    # Note: these header labels are for stakeholders and do not match the
    # Rails DB names in all cases, e.g. added_to_system_at header is case_contact.created_at
    {
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
  end

  def fixed_column_values(case_contact)
    CaseContactsExportCsvService.fixed_columns(case_contact).slice(*filtered_columns).values
  end

  def court_topic_answers(case_contact)
    case_contact.contact_topic_answers.map(&:value)
  end

  def court_topics
    @base_scope
      .has_court_topics
      .select("contact_topics_contact_topic_answers.question")
      .distinct
      .map(&:question)
  end
end
