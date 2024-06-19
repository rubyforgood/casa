class CaseImporter < FileImporter
  IMPORT_HEADER = ["case_number", "case_assignment", "birth_month_year_youth", "next_court_date"]

  def self.import_cases(csv_filespec, org_id)
    new(csv_filespec, org_id).import_cases
  end

  def initialize(csv_filespec, org_id)
    super(csv_filespec, org_id, "casa_cases", ["case_number", "case_assignment", "birth_month_year_youth", "next_court_date"])
  end

  def import_cases
    import do |row|
      casa_case_params = row.to_hash.slice(:case_number, :birth_month_year_youth).compact

      unless casa_case_params.key?(:case_number)
        raise "Row does not contain a case number."
      end

      casa_case = CasaCase.find_by(case_number: casa_case_params[:case_number], casa_org_id: org_id)
      volunteer_assignment_list = email_addresses_to_users(Volunteer, String(row[:case_assignment]))
      next_court_date = row[:next_court_date]

      if casa_case # Case exists try to update it
        unless casa_case.active
          raise "Case #{casa_case.case_number} already exists, but is inactive. Reactivate the CASA case instead."
        end

        update_casa_case(casa_case, casa_case_params, volunteer_assignment_list, next_court_date)
      else # Case doesn't exist try to create a new case
        create_casa_case(casa_case_params, volunteer_assignment_list, next_court_date)
      end
    end
  end

  private

  def create_casa_case(case_params, volunteer_assignment_list, next_court_date)
    casa_case = CasaCase.new(case_params)
    casa_case.casa_org_id = org_id
    casa_case.save!

    casa_case.court_dates.create(date: next_court_date)
    casa_case.volunteers << volunteer_assignment_list

    casa_case
  end

  def update_casa_case(casa_case, case_params, volunteer_assignment_list, next_court_date)
    if record_outdated?(casa_case, case_params)
      casa_case.update(case_params)
    end

    if casa_case.next_court_date.nil?
      casa_case.court_dates.create(date: next_court_date)
    end

    volunteer_assignment_list.each do |volunteer|
      # Expecting an array of length 0 or 1
      assignments = casa_case.case_assignments.where(volunteer: volunteer)

      if assignments.empty?
        casa_case.volunteers << volunteer
      elsif assignments[0].inactive?
        assignments[0].update(active: true)
      end
    end
  end
end
