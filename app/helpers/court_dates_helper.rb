module CourtDatesHelper
  def when_do_we_have_court_dates(casa_case)
    court_dates = casa_case.court_dates.includes(:hearing_type).ordered_ascending.load
    past = false
    future = false

    court_dates.each do |court_date|
      court_date.date <= Date.current ? past = true : future = true
    end

    if future && !past
      'future'
    elsif !future && past
      'past'
    end
  end
end
