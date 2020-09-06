class FileImporter
  require "csv"

  attr_reader :csv_filespec, :org_id, :number_imported, :failed_imports

  def initialize(import_csv, org_id)
    @csv_filespec = import_csv
    @org_id = org_id
    @failed_imports = []
    @number_imported = 0
  end

  def import
    @number_imported = 0
    CSV.foreach(csv_filespec || [], headers: true, header_converters: :symbol) do |row|
      yield(row)
      @number_imported += 1
    rescue StandardError => e
      @failed_imports << row.to_hash.values.to_s
    end
  end

  private

  def result_hash(type)
    successful_import_message = "You successfully imported #{number_imported} #{type}"
    if failed_imports.empty?
      {type: :success, message: "#{successful_import_message}."}
    else
      {type: :error, message: "#{successful_import_message}, "\
        "the following #{type} were not imported: #{failed_imports.join(", ")}."}
    end
  end

  def gather_users(comma_separated_emails)
    comma_separated_emails.split(",")
      .map { |email| User.find_by(email: email.strip) }
      .compact
  end
end
