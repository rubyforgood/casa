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

  # Is the More-filters panel open? This is the USER's state, round-tripped through the form, not
  # re-derived from the params on every render. The filter bar auto-submits, so deriving it meant the
  # panel snapped shut whenever the last hidden filter went away -- clearing the contact types, or
  # setting a select back to All -- and even when the user merely ticked Hide drafts with the panel
  # open. `expand_filters?` is only the DEFAULT, for arriving with hidden filters already in the URL.
  def filters_open?
    return params[:filters_open] == "1" if params.key?(:filters_open)

    expand_filters?
  end

  def expand_filters?(surfaced_keys = %i[no_drafts sorted_by])
    params.fetch(:filterrific, {})
      .except(*surfaced_keys)
      .reject { |_, value| value == "" }
      .present?
  end

  # Human names for the applied-filter chips.
  FILTER_LABELS = {
    "occurred_starting_at" => "From",
    "occurred_ending_at" => "To",
    "contact_type" => "Contact types",
    "contact_medium" => "Contact medium",
    "want_driving_reimbursement" => "Want driving reimbursement",
    "contact_made" => "Contact made",
    "no_drafts" => "Hide drafts"
  }.freeze

  # Is anything actually filtering? The Clear action only renders when there is something to
  # clear -- a Clear button sitting at the defaults is dead chrome. Note `no_drafts` always
  # posts ("0" when unchecked) and array filters arrive as [""], so neither can be judged by bare
  # presence. SORT IS NOT A FILTER: a non-default sort must not put a button labelled "Clear
  # filters" on screen, and clearing must not reset the user's sort.
  def filters_applied?
    applied_filter_params.any?
  end

  # One chip per applied filter, each carrying the URL that removes just that one. Showing WHICH
  # filters are on is the part that makes a collapsed panel safe (Polaris / Linear / Jira all do
  # this); a count alone leaves the user guessing.
  def applied_filter_chips
    applied_filter_params.map do |key, value|
      {
        label: FILTER_LABELS.fetch(key, key.humanize),
        value: filter_chip_value(key, value),
        remove_path: filter_path_without(key)
      }
    end
  end

  # Everything cleared, sort kept -- unlike `reset_filterrific_url`, which drops the sort too.
  def clear_filters_path
    filter_path_with({})
  end

  private

  # The filterrific params that are actually filtering, as a plain hash. Sort is excluded
  # throughout: it is a sort, not a filter.
  def applied_filter_params
    filterrific = params[:filterrific]
    return {} if filterrific.blank?

    # each_pair, not select: ActionController::Parameters is not Enumerable.
    filterrific.each_pair.each_with_object({}) do |(key, value), applied|
      key = key.to_s
      next if key == "sorted_by"
      next unless filter_applied?(key, value)

      applied[key] = value.is_a?(ActionController::Parameters) ? value.to_unsafe_h : value
    end
  end

  def filter_path_without(key)
    filter_path_with(applied_filter_params.except(key))
  end

  # ALWAYS sends a filterrific hash (sorted_by at minimum). Filterrific falls back to its
  # session-persisted params when the submitted hash is blank, so an empty one would resurrect the
  # filters this link is meant to drop. Case scope and panel state are not filters, so they survive.
  def filter_path_with(filters)
    case_contacts_path({
      casa_case_id: params[:casa_case_id].presence,
      filters_open: params[:filters_open].presence,
      filterrific: {"sorted_by" => current_sorted_by}.merge(filters)
    }.compact)
  end

  def current_sorted_by
    params.dig(:filterrific, :sorted_by).presence || default_sorted_by
  end

  def filter_chip_value(key, value)
    case key
    when "no_drafts" then nil # the label already says it
    when "contact_made", "want_driving_reimbursement" then ActiveModel::Type::Boolean.new.cast(value) ? "Yes" : "No"
    when "contact_medium" then value.to_s.tr("-", " ").humanize
    when "contact_type" then ContactType.where(id: Array.wrap(value)).order(:name).pluck(:name).to_sentence
    else value.to_s
    end
  end

  def filter_applied?(key, value)
    case key
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
