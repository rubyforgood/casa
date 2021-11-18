module MileageRatesHelper
  def effective_date_parser(date)
    date = DateTime.current if date.blank?
    date.strftime(::DateHelper::RUBY_MONTH_DAY_YEAR_FORMAT)
  end
end
