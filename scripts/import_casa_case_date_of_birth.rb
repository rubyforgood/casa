# This will be run by hand with real prod data in prod console,
# because we don't want to check in the data
# and we don't want to make Sarah from PG CASA do hundreds of these by hand in the UI
# because import didn't have DOB when PG CASA onboarded.

# data = """
# 1/21/2000,,,,CINA 11-1234,
# 2/22/2000,,,,TPR 12-1234,
# 3/23/2000,,,,CINA 13-1234,
# """

def update_casa_case_birth_month_year_youth(casa_case, new_date)
  casa_case.update!(birth_month_year_youth: Date.new(new_date.year, new_date.month, 1))
end

def dates_match(casa_case, new_date)
  casa_case.birth_month_year_youth.year == new_date.year && casa_case.birth_month_year_youth.month == new_date.month
end

def update_casa_case_dates_of_birth(data, case_not_found, already_has_nonmatching_date, no_edit_made, updated_casa_cases)
  casa_org = CasaOrg.find_by(name: "Prince George CASA")
  return "Prince George CASA not found" unless casa_org
  data.split("\n").map(&:strip).reject(&:empty?).each do |row|
    chunks = row.split(",").compact
    d1 = chunks[0]
    p d1
    d2 = Date.strptime(d1, "%m/%d/%Y") # https://ruby-doc.org/stdlib-2.4.1/libdoc/date/rdoc/Date.html#method-i-strftime
    p d2
    case_number = chunks.last
    cc = CasaCase.find_by(case_number: case_number, casa_org_id: casa_org.id)
    
    process_casa_case_date(cc, import_date, case_number, already_has_nonmatching_date, no_edit_made, updated_casa_cases, case_not_found)
  end
  { not_found: case_not_found, nonmatching: already_has_nonmatching_date, no_edit_made: no_edit_made, updated_casa_cases: updated_casa_cases }
end

def process_casa_case_date(cc, import_date, case_number, already_has_nonmatching_date, no_edit_made, updated_casa_cases, case_not_found)
  if cc&.birth_month_year_youth
    if !dates_match(cc, d2)
      already_has_nonmatching_date << { case_number: case_number, prev_date: cc.birth_month_year_youth, import_date: d2 }
    else
      no_edit_made << cc.case_number
    end
  elsif cc
    update_casa_case_birth_month_year_youth(cc, d2)
    updated_casa_cases << cc.case_number
  else
    case_not_found << case_number
  end
end

# data = """
# 1/21/2000,,,,CINA 11-1234,
# 2/22/2000,,,,TPR 12-1234,
# 3/23/2000,,,,CINA 13-1234,
# """
# case_not_found = []
# already_has_nonmatching_date = []
# no_edit_made = []
# updated_casa_cases = []
# r1 = update_casa_case_dates_of_birth(data, case_not_found, already_has_nonmatching_date, no_edit_made, updated_casa_cases)
# r1
# puts CasaCase.all.pluck(:case_number, :birth_month_year_youth).map {|i| i.join(", ")}.sort
