# Helper methods for new case contact form
module CaseContactsHelper
  def duration_hours(case_contact)
    case_contact.duration_minutes.to_i.div(60)
  end

  def duration_minutes(case_contact)
    case_contact.duration_minutes.to_i.remainder(60)
  end

  def set_contact_made_false(case_contact)
    case_contact.persisted? && case_contact.contact_made == false
  end

  def contact_mediums
    CaseContact::CONTACT_MEDIUMS.map { |contact_medium|
      OpenStruct.new(value: contact_medium, label: contact_medium.titleize)
    }
  end

  def render_back_link(casa_case)
    return send_home if !current_user || current_user&.volunteer?

    send_to_case(casa_case)
  end

  private

  def send_home
    root_path
  end

  def send_to_case(casa_case)
    casa_case_path(casa_case)
  end
end
