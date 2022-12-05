# frozen_string_literal: true

# Helper methods for court_dates
module CourtDatesHelper
  def when_do_we_have_court_dates(casa_case)
    date_query = casa_case.court_dates.includes(:hearing_type).ordered_ascending
    last_court_date = date_query.last
    first_court_date = date_query.first

    if last_court_date.date < Date.current
      'past'
    elsif last_court_date.date > Date.current && first_court_date.date > Date.current
      'future'
    end
  end
end
