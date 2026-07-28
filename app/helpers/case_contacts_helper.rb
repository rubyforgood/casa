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

  # Filters that live in the always-visible toolbar row rather than behind `More filters`.
  SURFACED_FILTERS = %w[no_drafts sorted_by].freeze

  # How many of the *hidden* filters are active, for the count badge on the overflow trigger.
  # Counts FIELDS, not values: three contact types picked is one active filter, which is what the
  # badge means (and what Jira / Polaris count). Sort and Hide drafts are excluded -- they are
  # visible in the row, so the badge would double-report them.
  def hidden_filter_count
    filterrific = params[:filterrific]
    return 0 if filterrific.blank?

    filterrific.each_pair.count do |key, value|
      SURFACED_FILTERS.exclude?(key.to_s) && filter_applied?(key.to_s, value)
    end
  end

  def expand_filters?(surfaced_keys = %i[no_drafts sorted_by])
    params.fetch(:filterrific, {})
      .except(*surfaced_keys)
      .reject { |_, value| value == "" }
      .present?
  end

  # Is anything actually filtering? The Clear action only renders when there is something to
  # clear -- a Clear button sitting at the defaults is dead chrome. Note `no_drafts` always
  # posts ("0" when unchecked) and array filters arrive as [""], so neither can be judged by
  # bare presence, and a default sort is not something the user set.
  def filters_applied?
    filterrific = params[:filterrific]
    return false if filterrific.blank?

    # each_pair, not any?: ActionController::Parameters is not Enumerable.
    filterrific.each_pair.any? { |key, value| filter_applied?(key.to_s, value) }
  end

  private

  def filter_applied?(key, value)
    case key
    when "sorted_by" then value.present? && value.to_s != default_sorted_by
    when "no_drafts" then ActiveModel::Type::Boolean.new.cast(value).present?
    else Array.wrap(value).any?(&:present?)
    end
  end

  def default_sorted_by
    CaseContact.filterrific_default_filter_params.with_indifferent_access[:sorted_by].to_s
  end

  def send_home
    root_path
  end

  def send_to_case(casa_case)
    casa_case_path(casa_case)
  end
end
