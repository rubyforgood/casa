class SupervisorImporter < FileImporter
  IMPORT_HEADER = ["email", "display_name", "supervisor_volunteers"]

  def self.import_supervisors(csv_filespec, org_id)
    new(csv_filespec, org_id).import_supervisors
  end

  def initialize(csv_filespec, org_id)
    super(csv_filespec, org_id, "supervisors", ["email", "display_name", "supervisor_volunteers"])
  end

  def import_supervisors
    failures = []

    import do |row|
      supervisor_params = row.to_hash.slice(:display_name, :email).compact

      if !supervisor_params.key?(:email)
        failures << "ERROR: The row \n  #{row}\n  does not contain an email address"
        next
      end

      begin
        supervisor = Supervisor.find_by(email: supervisor_params[:email])
        volunteer_assignment_list = email_addresses_to_users(Volunteer, String(row[:supervisor_volunteers]))

        if volunteer_assignment_list.count != String(row[:supervisor_volunteers]).split(",").count
          failures << "ERROR: The row \n  #{row}\n  contains unimported volunteers"
          next
        end

        if supervisor # Supervisor exists try to update it
          update_supervisor(supervisor, supervisor_params, volunteer_assignment_list)
        else # Supervisor doesn't exist try to create a new supervisor
          supervisor = create_user_record(Supervisor, supervisor_params)
        end

        volunteer_assignment_list.each do |volunteer|
          if volunteer.supervisor
            next if volunteer.supervisor == supervisor

            failures << "Volunteer #{volunteer.email} already has a supervisor"
          else
            supervisor.volunteers << volunteer
          end
        end
      rescue => error
        failures << error.to_s
      end

      raise failures.join("\n") unless failures.empty?
    end
  end

  def update_supervisor(supervisor, supervisor_params, volunteer_assignment_list)
    if record_outdated?(supervisor, supervisor_params)
      supervisor.update(supervisor_params)
    end
  end
end
