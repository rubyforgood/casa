# This will be run by hand with real prod data in prod console,
# because we don't want to check in the data
# and we don't want to make Sarah from PG CASA do hundreds of these by hand in the UI
# because import didn't take DOC when PGCASA onboarded.

# data = """
# 1/21/2000,,,,CINA 11-1234,
# 2/22/2000,,,,TPR 12-1234,
# 3/23/2000,,,,CINA 13-1234,
# """

def update_casa_case_dates_of_birth(data)
  case_not_found = []
  already_has_nonmatching_date = []
  data.split("\n").map(&:strip).reject(&:empty?).each do |row|
    chunks = row.split(",").compact
    d1 = chunks[0]
    p d1
    d2 = Date.strptime(d1, "%m/%d/%Y") # https://ruby-doc.org/stdlib-2.4.1/libdoc/date/rdoc/Date.html#method-i-strftime
    p d2

    case_number = chunks.last
    cc = CasaCase.find_by(case_number: case_number)
    if cc
      if cc.birth_month_year_youth && (cc.birth_month_year_youth.year != d2.year || cc.birth_month_year_youth.month != d2.month)
        already_has_nonmatching_date << {cc_id: cc.id, prev_date: cc.birth_month_year_youth, import_date: d2}
      end
      p [d2.year, d2.month, 1]
      cc.update!(birth_month_year_youth: Date.new(d2.year, d2.month, 1))
    else
      case_not_found << case_number
    end
  end
  {not_found: case_not_found, nonmatching: already_has_nonmatching_date}
end
