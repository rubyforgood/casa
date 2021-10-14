module DateHelper
  def validate_date(day, month, year)
    raise Date::Error if day.blank? || month.blank? || year.blank?

    Date.parse("#{day}-#{month}-#{year}")
  end

  def parse_date(errors, date_field_name, args)
    day = args.delete("#{date_field_name}(3i)")
    month = args.delete("#{date_field_name}(2i)")
    year = args.delete("#{date_field_name}(1i)")

    return args if day.blank? && month.blank? && year.blank?

    args[date_field_name.to_sym] = validate_date(day, month, year)
    args
  rescue Date::Error
    errors.add(date_field_name.to_sym, "was not a valid date.")
    args
  end

  def pre_transition_aged_youth_age
    Date.current - 14.years
  end
end
