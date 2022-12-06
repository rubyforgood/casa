# frozen_string_literal: true

# Helper methods for court_dates
module CourtDatesHelper
  def when_do_we_have_court_dates(casa_case)
    court_dates = casa_case.court_dates.ordered_ascending
    date_now = Date.current

    if court_dates.last.date < date_now
      "past"
    elsif court_dates.first.date > date_now
      "future"
    end
  end
end
