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
      @failed_imports << row.to_hash.values.to_s
    end
  end

  private

  def result_hash(pluralized_type_label)
    message = ["You successfully imported #{@number_imported} #{pluralized_type_label}."]
    if failed_imports.empty? && failed_volunteers.empty?
      message_type = :success
    else
      message_type = :error
      if failed_imports.present?
        message << "The following #{pluralized_type_label} were not imported: #{failed_imports.join(", ")}."
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

  def email_addresses_to_users(clazz, comma_separated_emails)
    comma_separated_emails.split(",")
      .map { |email| clazz.find_by(email: email.strip) }
      .compact
      .sort
  end
end
