class FileImporter
  require "csv"

  attr_reader :csv_filespec, :org_id, :number_imported, :failed_imports, :failed_volunteers

  def initialize(csv_filespec, org_id)
    @csv_filespec = csv_filespec
    @org_id = org_id
    @failed_imports = []
    @failed_volunteers = []
    @number_imported = 0
  end

  def import
    @number_imported = 0
    CSV.foreach(csv_filespec || [], headers: true, header_converters: :symbol) do |row|
      yield(row)
      @number_imported += 1
    rescue
      @failed_imports << row.to_hash.values
    end
  end

  class Result
    attr_reader :type_label, :number_imported, :failed_imports, :failed_volunteers

    def initialize(type_label, number_imported, failed_imports, failed_volunteers)
      @type_label = type_label
      @number_imported = number_imported
      @failed_imports = failed_imports
      @failed_volunteers = failed_volunteers
    end

    def failed_volunteers?
      !failed_volunteers.blank?
    end

    def failed_imports?
      !failed_imports.blank?
    end

    def failed?
      failed_volunteers? || failed_imports?
    end

    def success?
      !failed?
    end

    def message
      messages = []
      messages << "You successfully imported #{@number_imported} #{@type}." if @number_imported > 0
      messages << "Not all rows were imported." if failed?
      messages.join(" ")
    end

    def status
      success? ? :success : :error
    end

    def export_failed_imports
      CSV.generate do |csv|
        csv << ["display_name", "email"]
        failed_imports.each do |display_name, email|
          csv << [display_name, email]
        end
      end
    end

    def export_failed_volunteers
      CSV.generate do |csv|
        csv << ["email", "display_name", "supervisor_volunteers"]
        failed_volunteers.each do |volunteer, supervisor|
          csv << [volunteer.email, volunteer.display_name, supervisor.email]
        end
      end
    end
  end

  private

  def result_hash(pluralized_type_label)
    result = Result.new(pluralized_type_label, number_imported, failed_imports, failed_volunteers)

    hash = {
      type: result.status,
      message: result.message,
    }
    hash[:exported_rows] = result.export_failed_imports unless failed_imports.empty?
    hash[:exported_rows] = result.export_failed_volunteers unless failed_volunteers.empty?
    hash

    # message = ["You successfully imported #{@number_imported} #{pluralized_type_label}."]
    # if success?
    #   message_type = :success
    # else
    #   message_type = :error
    #   if failed_imports?
    #     message << "The following #{pluralized_type_label} were not imported: #{failed_imports.join(", ")}."
    #   end
    #   if failed_volunteers?
    #     message << "The following volunteers were not imported:"
    #     message << failed_volunteers.map { |volunteer, supervisor, row_num|
    #       "#{volunteer.email} was not assigned to supervisor #{supervisor.email} on row ##{row_num}"
    #     }.join(", ")
    #   end
    # end
    # {type: message_type, message: message.join(" ")}
  end

  def email_addresses_to_users(clazz, comma_separated_emails)
    comma_separated_emails.split(",")
      .map { |email| clazz.find_by(email: email.strip) }
      .compact
      .sort
  end
end
