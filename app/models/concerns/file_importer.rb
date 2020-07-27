class FileImporter
  require "csv"

  def self.import_volunteers(import_csv, org_id)
    CSV.foreach(import_csv, headers: true, header_converters: :symbol) do |row|
      user = User.new(row.to_hash)
      user.role = "volunteer"
      user.casa_org_id = org_id
      user.password = "123456"
      if user.save
        user.invite!
      end
    end
  end

  def self.import_supervisors(import_csv, org_id)
    CSV.foreach(import_csv, headers: true, header_converters: :symbol) do |row|
      user = User.new(email: row[:email], display_name: row[:display_name])
      user.role = "supervisor"
      user.casa_org_id = org_id
      user.password = "123456"
      if user.save
        user.invite!
        volunteers = row[:supervisor_volunteers]
        lookups = volunteers.split(",").map { |email| User.find_by(email: email.strip) }
        user.volunteers << lookups.compact if lookups.compact.present?
      end
    end
  end

  def self.import_cases(import_csv, org_id)
    CSV.foreach(import_csv, headers: true, header_converters: :symbol) do |row|
      casa_case = CasaCase.new(case_number: row[:case_number], transition_aged_youth: row[:transition_aged_youth])
      if casa_case.save
        volunteers = row[:case_assignment]
        lookups = volunteers.split(",").map { |email| User.find_by(email: email.strip) }
        casa_case.volunteers << lookups.compact if lookups.compact.present?
      end
    end
  end
end

