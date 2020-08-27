class CaseImporter < FileImporter
  def import_cases
    import do |row|
      casa_case = CasaCase.new(row.to_hash.slice(:case_number, :transition_aged_youth))
      casa_case.casa_org_id = org_id
      casa_case.save!
      casa_case.volunteers << gather_users(String(row[:case_assignment]))
    end
    result_hash("casa_cases")
  end
end