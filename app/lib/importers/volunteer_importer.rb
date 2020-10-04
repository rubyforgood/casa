class VolunteerImporter < FileImporter
  IMPORT_HEADER = ["display_name", "email"]

  def self.import_volunteers(csv_filespec, org_id)
    new(csv_filespec, org_id).import_volunteers
  end

  def initialize(csv_filespec, org_id)
    super(csv_filespec, org_id, "volunteers", ["display_name", "email"])
  end

  def import_volunteers
    import do |row|
      result = create_user_record(Volunteer, row)
      user = result[:user]

      raise "Volunteer #{user.email} already exists" if result[:existing]
    end
  end
end
