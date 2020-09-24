class UserImporter < FileImporter
  def self.import_volunteers(csv_filespec, org_id)
    new(csv_filespec, org_id, "volunteers", ["display_name", "email"]).import_volunteers
  end

  def self.import_supervisors(csv_filespec, org_id)
    new(csv_filespec, org_id, "supervisors", ["email", "display_name", "supervisor_volunteers"]).import_supervisors
  end

  def import_volunteers
    import do |row|
      result = create_user_record(Volunteer, row)
      user = result[:user]
      raise "Volunteer #{user.email} already exists" if result[:existing]
    end
  end

  def import_supervisors
    import do |row|
      result = create_user_record(Supervisor, row)
      supervisor = result[:user]
      if supervisor
        failures = []
        failures << "Supervisor #{supervisor.email} already exists" if result[:existing]
        email_addresses_to_users(Volunteer, String(row[:supervisor_volunteers])).each do |volunteer|
          begin
            if volunteer.supervisor
              next if volunteer.supervisor == supervisor

              failures << "Volunteer #{volunteer.email} already has a supervisor"
            else
              supervisor.volunteers << volunteer
            end
          rescue StandardError => error
            failures << error.to_s
          end
        end
      end

      raise failures.join("\n") unless failures.empty?
    end
  end

  private

  def create_user_record(user_class, row_data)
    user_params = row_data.to_hash.slice(:display_name, :email)
    user = user_class.find_by(user_params)
    return { user: user, existing: true } if user.present?

    user = user_class.new(user_params)
    user.casa_org_id, user.password = org_id, SecureRandom.hex(10)
    user.save!
    user.invite!
    { user: user, existing: false }
  end
end
