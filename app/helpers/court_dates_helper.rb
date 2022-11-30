module CourtDatesHelper
  def when_do_we_have_court_dates(casa_case)
    court_dates = casa_case.court_dates.includes(:hearing_type).ordered_ascending.load
    past = []
    future = []

    court_dates.each do |date|
      Date.current.to_time.after?(date.date.to_time) ?  past.push(date.date.to_time) : future.push(date.date.to_time)
    end

    return past, future
  end
end
