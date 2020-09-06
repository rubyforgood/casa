class UserImporter < FileImporter

  def import_volunteers
    import do |row|
      create_user_record(Volunteer, row)
    end
    result_hash("volunteers")
  end

  def import_supervisors
    import do |row|
      supervisor = create_user_record(Supervisor, row)
      gather_users(Volunteer, String(row[:supervisor_volunteers])).each { |volunteer|
        if !volunteer.supervisor
          supervisor.volunteers << volunteer
        end
      }
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
