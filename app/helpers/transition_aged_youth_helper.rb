module TransitionAgedYouthHelper
  TRANSITION_AGE_YOUTH_ICON = "🦋".freeze
  NON_TRANSITION_AGE_YOUTH_ICON = "🐛".freeze
  TRANSITION_AGE_YEARS_AGO = 14.years.ago

  def in_transition_age?
    birth_month_year_youth.nil? ? false : birth_month_year_youth <= TRANSITION_AGE_YEARS_AGO
  end
end
