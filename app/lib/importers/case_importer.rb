class CaseImporter < FileImporter
  IMPORT_HEADER = ["case_number", "case_assignment", "birth_month_year_youth"]

  def self.import_cases(csv_filespec, org_id)
    new(csv_filespec, org_id).import_cases
  end

  def initialize(csv_filespec, org_id)
    super(csv_filespec, org_id, "casa_cases", ["case_number", "case_assignment", "birth_month_year_youth"])
  end

  def import_cases
    import do |row|
      casa_case_params = row.to_hash.slice(:case_number, :transition_aged_youth, :birth_month_year_youth).compact

      unless casa_case_params.key?(:case_number)
        raise "Row does not contain a case number."
      end

      casa_case = CasaCase.find_by(case_number: casa_case_params[:case_number], casa_org_id: org_id)
      volunteer_assignment_list = email_addresses_to_users(Volunteer, String(row[:case_assignment]))

      if casa_case # Case exists try to update it
        unless casa_case.active
          raise "Case #{casa_case.case_number} already exists, but is inactive. Reactivate the CASA case instead."
        end

        update_casa_case(casa_case, casa_case_params, volunteer_assignment_list)
      else # Case doesn't exist try to create a new case
        create_casa_case(casa_case_params, volunteer_assignment_list)
      end
    end
  end

  private

  def create_casa_case(case_params, volunteer_assignment_list)
    casa_case = CasaCase.new(case_params)
    casa_case.casa_org_id = org_id
    casa_case.save!

    casa_case.volunteers << volunteer_assignment_list

    casa_case
  end

  def update_casa_case(casa_case, case_params, volunteer_assignment_list)
    if record_outdated?(casa_case, case_params)
      casa_case.update(case_params)
    end

    volunteer_assignment_list.each do |volunteer|
      # Expecting an array of length 0 or 1
      assignment = casa_case.case_assignments.where(volunteer: volunteer)

      if assignment.empty?
        casa_case.volunteers << volunteer
      elsif !assignment[0].active
        assignment[0].update(active: true)
      end
    end
  end
end
