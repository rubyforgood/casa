class UserImporter < FileImporter
  def self.import_volunteers(csv_filespec, org_id)
    new(csv_filespec, org_id).import_volunteers
  end

  def self.import_supervisors(csv_filespec, org_id)
    new(csv_filespec, org_id).import_supervisors
  end

  def import_volunteers
    import do |row|
      create_user_record(Volunteer, row)
    end
    result_hash("volunteers")
  end

  def import_supervisors
    import do |row|
      supervisor = create_user_record(Supervisor, row)
      if supervisor
        email_addresses_to_users(Volunteer, String(row[:supervisor_volunteers])).each do |volunteer|
          if volunteer.supervisor
            @failed_volunteers << [volunteer, supervisor, index]
          else
            supervisor.volunteers << volunteer
          end
        end
      else
        # TODO: This should be unreachable because `user.save!` will throw an error on failure, right?
        # Should we use `user.save` instead?
        @failed_imports << row.to_hash.values.to_s
      end
    end

    result_hash("supervisors")
  end

  private

  def create_user_record(user_class, row_data)
    user = user_class.new(row_data.to_hash.slice(:display_name, :email))
    user.casa_org_id, user.password = org_id, SecureRandom.hex(10)
    user.save!
    user.invite!
    user
  end
end
