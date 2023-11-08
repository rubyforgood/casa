Date::DATE_FORMATS[:short_ordinal] = ->(date) { date.strftime("%B #{date.day.ordinalize}") }
Date::DATE_FORMATS[:slashes] = "%Y/%m/%d"
