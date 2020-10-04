class SupervisorImporter < FileImporter
  IMPORT_HEADER = ["email", "display_name", "supervisor_volunteers"]

  def self.import_supervisors(csv_filespec, org_id)
    new(csv_filespec, org_id).import_supervisors
  end

  def initialize(csv_filespec, org_id)
    super(csv_filespec, org_id, "supervisors", ["email", "display_name", "supervisor_volunteers"])
  end

  def import_supervisors
    import do |row|
      result = create_user_record(Supervisor, row)
      supervisor = result[:user]
      if supervisor
        failures = []
        failures << "Supervisor #{supervisor.email} already exists" if result[:existing]
        email_addresses_to_users(Volunteer, String(row[:supervisor_volunteers])).each do |volunteer|
          if volunteer.supervisor
            next if volunteer.supervisor == supervisor

            failures << "Volunteer #{volunteer.email} already has a supervisor"
          else
            supervisor.volunteers << volunteer
          end
        rescue => error
          failures << error.to_s
        end
      end

      raise failures.join("\n") unless failures.empty?
    end
  end
end
