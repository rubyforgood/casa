class UserImporter < FileImporter

  def import_volunteers
    import do |row|
      create_user_record(Volunteer, row)
    end
    result_hash("volunteers")
  end

  def import_supervisors
    import do |row|
      user = create_user_record(Supervisor, row)
      user.volunteers << gather_users(String(row[:supervisor_volunteers]))
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