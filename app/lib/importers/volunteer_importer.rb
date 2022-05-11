class VolunteerImporter < FileImporter
  IMPORT_HEADER = ["display_name", "email", "phone_number"]

  def self.import_volunteers(csv_filespec, org_id)
    new(csv_filespec, org_id).import_volunteers
  end

  def initialize(csv_filespec, org_id)
    super(csv_filespec, org_id, "volunteers", ["display_name", "email", "phone_number"])
  end

  def import_volunteers
    import do |row|
      volunteer_params = row.to_hash.slice(:display_name, :email, :phone_number).compact

      unless volunteer_params.key?(:email)
        raise "Row does not contain an e-mail address."
      end

      volunteer_params[:phone_number] = volunteer_params.key?(:phone_number) ? "+#{volunteer_params[:phone_number]}" : ""
      volunteer_params[:receive_sms_notifications] = !volunteer_params[:phone_number].empty?

      volunteer = Volunteer.find_by(email: volunteer_params[:email])

      if volunteer # Volunteer exists try to update it
        update_volunteer(volunteer, volunteer_params)
      else # Volunteer doesn't exist try to create a new supervisor
        create_user_record(Volunteer, volunteer_params)
      end
    end
  end

  def update_volunteer(volunteer, volunteer_params)
    if record_outdated?(volunteer, volunteer_params)
      volunteer.update(volunteer_params)
    end
  end
end
