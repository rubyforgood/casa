class SupervisorImporter < FileImporter
  IMPORT_HEADER = ["email", "display_name", "supervisor_volunteers", "phone_number"]

  def self.import_supervisors(csv_filespec, org_id)
    new(csv_filespec, org_id).import_supervisors
  end

  def initialize(csv_filespec, org_id)
    super(csv_filespec, org_id, "supervisors", ["email", "display_name", "supervisor_volunteers", "phone_number"])
  end

  def import_supervisors
    import do |row|
      supervisor_params = row.to_hash.slice(:display_name, :email, :phone_number).compact

      unless supervisor_params.key?(:email)
        raise "Row does not contain e-mail address."
      end

      supervisor_params[:phone_number] = supervisor_params.key?(:phone_number) ? "+#{supervisor_params[:phone_number]}" : ""
      supervisor_params[:receive_sms_notifications] = !supervisor_params[:phone_number].empty?

      supervisor = Supervisor.find_by(email: supervisor_params[:email])
      volunteer_assignment_list = email_addresses_to_users(Volunteer, String(row[:supervisor_volunteers]))

      if volunteer_assignment_list.count != String(row[:supervisor_volunteers]).split(",").count
        raise "Row contains unimported volunteers."
      end

      if supervisor # Supervisor exists try to update it
        update_supervisor(supervisor, supervisor_params, volunteer_assignment_list)
      else # Supervisor doesn't exist try to create a new supervisor
        supervisor = create_user_record(Supervisor, supervisor_params)
      end

      assign_volunteers(supervisor, volunteer_assignment_list)
    end
  end

  def update_supervisor(supervisor, supervisor_params, volunteer_assignment_list)
    if record_outdated?(supervisor, supervisor_params)
      supervisor.update(supervisor_params)
    end
  end

  def assign_volunteers(supervisor, volunteer_assignment_list)
    volunteer_assignment_list.select { |v| v.supervisor != supervisor }.each do |volunteer|
      if volunteer.supervisor
        raise "Volunteer #{volunteer.email} already has a supervisor"
      else
        supervisor.volunteers << volunteer
      end
    end
  end
end
