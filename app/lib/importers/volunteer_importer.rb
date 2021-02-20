class VolunteerImporter < FileImporter
  IMPORT_HEADER = ["display_name", "email"]

  def self.import_volunteers(csv_filespec, org_id)
    new(csv_filespec, org_id).import_volunteers
  end

  def initialize(csv_filespec, org_id)
    super(csv_filespec, org_id, "volunteers", ["display_name", "email"])
  end

  def import_volunteers
    failures = []

    import do |row|
      volunteer_params = row.to_hash.slice(:display_name, :email).compact

      if !(volunteer_params.key?(:email))
        failures << "ERROR: The row \n  #{row}\n  does not contain an email address"
        next
      end

      begin
        volunteer = Volunteer.find_by(email: volunteer_params[:email])

        if volunteer # Volunteer exists try to update it
          update_volunteer(volunteer, volunteer_params)
        else # Volunteer doesn't exist try to create a new supervisor
          create_user_record(Volunteer, volunteer_params)
        end
      rescue => error
        failures << error.to_s
      end

      raise failures.join("\n") unless failures.empty?
    end
  end

  def update_volunteer(volunteer, volunteer_params)
    if record_outdated?(volunteer, volunteer_params)
      volunteer.update(volunteer_params)
    end
  end
end
