class CaseImporter < FileImporter
  IMPORT_HEADER = ["case_number", "transition_aged_youth", "case_assignment", "birth_month_year_youth"]

  def self.import_cases(csv_filespec, org_id)
    new(csv_filespec, org_id).import_cases
  end

  def initialize(csv_filespec, org_id)
    super(csv_filespec, org_id, "casa_cases", ["case_number", "transition_aged_youth", "case_assignment", "birth_month_year_youth"])
  end

  def import_cases
    failures = []

    import_results = import do |row|
      casa_case_params = row.to_hash.slice(:case_number, :transition_aged_youth, :birth_month_year_youth)

      if !(casa_case_params.key?(:case_number))
        failures << "ERROR: The row \n  #{row}\n  does not contain a case number"
        break
      end

      casa_case = CasaCase.find_by(case_number: casa_case_params[:case_number], casa_org_id: org_id)
      volunteers = email_addresses_to_users(Volunteer, String(row[:case_assignment]))

      if casa_case # Case exists try to update it
        if !(casa_case.active)
          failures << "Case #{case_number} already exists, but is inactive. Reactivate the CASA case instead."
        end

        case_number = casa_case.case_number
      else # Case doesn't exist try to create a new case
        casa_case = create_casa_case(casa_case_params)
      end

      volunteers.each do |volunteer|
        if !(volunteer.casa_cases.exists?(casa_case.id))
          casa_case.volunteers << volunteer
        end
      rescue => error
        failures << error.to_s
      end
    end

    raise failures.join("\n") unless failures.empty?

    return import_results
  end

  private

  def create_casa_case(case_params)
    casa_case = CasaCase.new(case_params)
    casa_case.casa_org_id = org_id
    casa_case.save!

    return casa_case
  end

  def update_casa_case(casa_case, case_params)
  end
end
