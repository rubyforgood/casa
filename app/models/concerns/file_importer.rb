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
    failed_volunteers = []
    CSV.foreach(import_csv || [], headers: true, header_converters: :symbol).with_index(1) do |row, index|
      supervisor = Supervisor.new(row.to_hash.slice(:display_name, :email))
      supervisor.casa_org_id, supervisor.password = org_id, SecureRandom.hex(10)
      if supervisor.save
        supervisor.invite!
        volunteers = get_list_volunteers(String(row[:supervisor_volunteers]))
        volunteers.each do |volunteer|
          if volunteer.supervisor
            failed_volunteers << [volunteer, supervisor, index]
          else
            supervisor.volunteers << volunteer
          end
        end
        @number_imported += 1
      else
        @failed_imports << row.to_hash.values.to_s
      end
    rescue ActiveModel::UnknownAttributeError
      @failed_imports << row.to_hash.values.to_s
    end
    build_message("supervisors", failed_volunteers)
  end

  def import_cases
    CSV.foreach(import_csv || [], headers: true, header_converters: :symbol) do |row|
      casa_case = CasaCase.new(row.to_hash.slice(:case_number, :transition_aged_youth))
      casa_case.casa_org_id = org_id
      if casa_case.save
        volunteers = String(row[:case_assignment])
          .split(",")
          .map { |email| User.find_by(email: email.strip) }
          .compact
        casa_case.volunteers << volunteers if volunteers.present?
        @number_imported += 1
      else
        @failed_imports << row.to_hash.values.to_s
      end
    rescue ActiveModel::UnknownAttributeError
      @failed_imports << row.to_hash.values.to_s
    end
    build_message("casa_cases")
  end

  def build_message(type, failed_volunteers = [])
    message = ["You successfully imported #{@number_imported} #{type}."]
    if @failed_imports.empty? && failed_volunteers.empty?
      message_type = :success
    else
      message_type = :error
      if @failed_imports.present?
        message << "The following #{type} were not imported: #{@failed_imports.join(", ")}."
      end
      if failed_volunteers.present?
        message << "The following volunteers were not imported:"
        message << failed_volunteers.map { |volunteer, supervisor, row_num|
          "#{volunteer.email} was not assigned to supervisor #{supervisor.email} on row ##{row_num}"
        }.join(", ")
      end
    end
    {type: message_type, message: message.join(" ")}
  end
  
  def get_list_volunteers(volunteers_string)
    volunteers_string
      .split(",")
      .map { |email| User.find_by(email: email.strip) }
      .compact
  end
end
