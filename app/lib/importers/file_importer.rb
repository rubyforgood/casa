class FileImporter
  require "csv"

  ERR_NOT_ALL_IMPORTED = "Not all rows were imported."
  ERR_NO_ROWS = "File did not contain any rows."

  attr_reader :csv_filespec, :org_id, :type_label, :header_names, :number_imported, :failed_imports

  def initialize(csv_filespec, org_id, type_label, header_names)
    @csv_filespec = csv_filespec
    @org_id = org_id
    @type_label = type_label
    @header_names = header_names
    @failed_imports = []
    @number_imported = 0
  end

  def import
    @number_imported = 0
    @file_no_rows = true

    CSV.foreach(csv_filespec || [], headers: true, header_converters: :symbol) do |row|
      @file_no_rows = false
      yield(row)
      @number_imported += 1
    rescue => error
      # email for supervisor or volunteer
      # display name for supervisor or volunteer
      # case number for casa_case
      # birth month and year for casa_case

      failed_row = row.to_hash
      failed_row[:errors] = error.to_s
      @failed_imports << failed_row.values
    end

    {
      type: status,
      message: message,
      exported_rows: export_failed_imports
    }
  end

  private

  def create_user_record(user_class, user_params)
    user = user_class.new(user_params)
    user.casa_org_id, user.password = org_id, SecureRandom.hex(10)
    user.save!
    user.invite!

    user
  end

  def email_addresses_to_users(clazz, comma_separated_emails)
    emails = comma_separated_emails.split(",").map!(&:strip)
    clazz.where(email: [emails]).distinct.order(:email).to_a
  end

  def export_failed_imports
    return unless failed?

    headers = header_names
    headers << "errors (please remove this column before uploading again)"

    CSV.generate do |csv|
      csv << header_names

      failed_imports.each do |failed_import|
        csv << failed_import
      end
    end
  end

  def failed?
    !failed_imports.blank?
  end

  def message
    messages = []
    messages << "You successfully imported #{@number_imported} #{@type_label}." if @number_imported > 0
    messages << ERR_NO_ROWS if @file_no_rows
    messages << ERR_NOT_ALL_IMPORTED if failed?
    messages.join(" ")
  end

  def record_outdated?(record, new_data)
    new_data.each do |key, value|
      # The parser keeps boolean values as strings
      if record[key] != value || (value == ((record[key].in?([true, false]) && record[key]) ? "FALSE" : "TRUE"))
        return true
      end
    end

    false
  end

  def success?
    !failed? && !@file_no_rows
  end

  def status
    success? ? :success : :error
  end
end
