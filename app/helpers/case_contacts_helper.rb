# Helper methods for new case contact form
module CaseContactsHelper
  def duration_hours(case_contact)
    case_contact.duration_minutes.to_i.div(60)
  end

  def duration_minutes(case_contact)
    case_contact.duration_minutes.to_i.remainder(60)
  end

  # Sentence-case medium labels (design-system), matching CaseContactDecorator#medium_label:
  # "voice-only" -> "Voice only", "text/email" -> "Text/email".
  def contact_mediums
    CaseContact::CONTACT_MEDIUMS.map { |contact_medium|
      OpenStruct.new(value: contact_medium, label: contact_medium.tr("-", " ").humanize)
    }
  end

  # Brand-tinted badge for a case contact's medium (in person / video / voice / text / letter). The
  # medium name is both a native tooltip and the accessible name (role=img + aria-label), so the
  # icon isn't a mystery and screen readers announce it. Reused wherever the medium icon appears so
  # the icon and its label always travel together.
  def contact_medium_badge(case_contact)
    decorated = case_contact.decorate
    label = decorated.medium_label
    tag.span(
      tag.i("", class: decorated.medium_icon, aria: {hidden: true}),
      class: "grid h-8 w-8 shrink-0 place-items-center rounded-xl bg-brand-50 text-brand-600",
      role: "img",
      title: label,
      aria: {label: "Contact medium: #{label}"}
    )
  end

  def render_back_link(casa_case)
    return send_home if !current_user || current_user&.volunteer?

    send_to_case(casa_case)
  end

  def thank_you_message
    [
      "Thanks for all you do!",
      "Thank you for your hard work!",
      "Thank you for a job well done!",
      "Thank you for volunteering!",
      "Thanks for being a great volunteer!",
      "One of the greatest gifts you can give is your time!",
      "Those who can do, do. Those who can do more, volunteer.",
      "Volunteers do not necessarily have the time, they just have the heart."
    ].sample
  end

  def show_volunteer_reimbursement(casa_cases)
    if current_user.role == "Volunteer"
      show = casa_cases.map do |casa_case|
        casa_case.case_assignments.where(volunteer_id: current_user).first&.allow_reimbursement == true
      end
      show.any?
    else
      true
    end
  end

  def expand_filters?(surfaced_keys = %i[no_drafts sorted_by])
    params.fetch(:filterrific, {})
      .except(*surfaced_keys)
      .reject { |_, value| value == "" }
      .present?
  end

  private

  def send_home
    root_path
  end

  def send_to_case(casa_case)
    casa_case_path(casa_case)
  end
end
