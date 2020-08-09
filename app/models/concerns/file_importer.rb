class FileImporter
  require "csv"

  attr_reader :import_csv, :org_id

  def initialize(import_csv, org_id)
    @import_csv = import_csv
    @org_id = org_id
    @number_imported = 0
    @failed_imports = []
  end

  def import_volunteers
    CSV.foreach(import_csv || [], headers: true, header_converters: :symbol) do |row|
      # TODO DRY these methods
      user = Volunteer.new(row.to_hash.slice(:display_name, :email))
      user.casa_org_id, user.password = org_id, SecureRandom.hex(10)
      if user.save
        user.invite!
        @number_imported += 1
      else
        @failed_imports << row.to_hash.values.to_s
      end
    rescue ActiveModel::UnknownAttributeError
      @failed_imports << row.to_hash.values.to_s
    end
    build_message("volunteers")
  end

  def import_supervisors
    CSV.foreach(import_csv || [], headers: true, header_converters: :symbol) do |row|
      user = Supervisor.new(row.to_hash.slice(:display_name, :email))
      user.casa_org_id, user.password = org_id, SecureRandom.hex(10)
      if user.save
        user.invite!
        volunteers = row[:supervisor_volunteers]
        lookups = volunteers.split(",").map { |email| User.find_by(email: email.strip) }
        user.volunteers << lookups.compact if lookups.compact.present?
        @number_imported += 1
      else
        @failed_imports << row.to_hash.values.to_s
      end
    rescue ActiveModel::UnknownAttributeError
      @failed_imports << row.to_hash.values.to_s
    end
    build_message("supervisors")
  end

  def import_cases
    CSV.foreach(import_csv || [], headers: true, header_converters: :symbol) do |row|
      casa_case = CasaCase.new(row.to_hash.slice(:case_number, :transition_aged_youth))
      casa_case.casa_org_id = org_id
      if casa_case.save
        volunteers = row[:case_assignment]
        lookups = volunteers.split(",").map { |email| User.find_by(email: email.strip) }
        casa_case.volunteers << lookups.compact if lookups.compact.present?
        @number_imported += 1
      else
        @failed_imports << row.to_hash.values.to_s
      end
    rescue ActiveModel::UnknownAttributeError
      @failed_imports << row.to_hash.values.to_s
    end
    build_message("casa_cases")
  end

  def build_message(type)
    if @failed_imports.empty?
      {type: :success, message: "You successfully imported #{@number_imported} #{type}."}
    else
      {type: :error, message: "You successfully imported #{@number_imported} #{type}, the "\
        "following #{type} were not imported: #{@failed_imports.join(", ")}."}
    end
  end
end
