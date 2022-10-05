class MigrateCourtReportDueDateService
  def run!
    casa_cases = CasaCase.all

    casa_cases.each do |casa_case|
      casa_case_last_court_date = casa_case.court_dates.max_by { |court_date| court_date.date }
      if !casa_case_last_court_date.nil?
        if casa_case_last_court_date.court_report_due_date.nil?
          casa_case_last_court_date.court_report_due_date = casa_case.court_report_due_date
          casa_case_last_court_date.save
        end
      end
    end
  end
end
