class CaseImporter < FileImporter
  IMPORT_HEADER = ["case_number", "transition_aged_youth", "case_assignment", "birth_month_year_youth"]

  def self.import_cases(csv_filespec, org_id)
    new(csv_filespec, org_id).import_cases
  end

  def initialize(csv_filespec, org_id)
    super(csv_filespec, org_id, "casa_cases", ["case_number", "transition_aged_youth", "case_assignment", "birth_month_year_youth"])
  end

  def import_cases
    import do |row|
      result = create_casa_case(row)
      casa_case = result[:casa_case]
      if casa_case
        case_number = casa_case.case_number
        failures = []
        if result[:existing]
          failures << if result[:deactivated]
            "Case #{case_number} already exists, but is inactive. Reactivate the CASA case instead."
          else
            "Case #{case_number} already exists"
          end
        end
        volunteers = email_addresses_to_users(Volunteer, String(row[:case_assignment]))
        volunteers.each do |volunteer|
          if volunteer.casa_cases.exists?(casa_case.id)
            failures << "Volunteer #{volunteer.email} already assigned to #{case_number}"
          else
            casa_case.volunteers << volunteer
          end
        rescue => error
          failures << error.to_s
        end

        raise failures.join("\n") unless failures.empty?
      end
    end
  end

  private

  def create_casa_case(row_data)
    casa_case_params = row_data.to_hash.slice(:case_number, :transition_aged_youth, :birth_month_year_youth)
    casa_case = CasaCase.find_by(casa_case_params)

    return {casa_case: casa_case, existing: true, deactivated: true} if casa_case.present? && !casa_case.active

    return {casa_case: casa_case, existing: true, deactivated: false} if casa_case.present?

    casa_case = CasaCase.new(casa_case_params)
    casa_case.casa_org_id = org_id
    casa_case.save!

    {casa_case: casa_case, existing: false}
  end
end
