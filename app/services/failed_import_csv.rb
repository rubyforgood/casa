class FailedImportCsv
  require "csv"

  attr_accessor :failed_rows
  attr_reader :import_type, :user

  MAX_FILE_SIZE_BYTES = 250.kilobytes
  EXPIRATION_TIME = 24.hours

  def initialize(import_type:, user:, failed_rows: "")
    @failed_rows = failed_rows
    @import_type = import_type
    @user = user
  end

  def store
    if failed_rows.bytesize > MAX_FILE_SIZE_BYTES
      Rails.logger.warn(max_size_warning)
      @failed_rows = max_size_warning
    end

    FileUtils.mkdir_p(File.dirname(csv_filepath))
    File.write(csv_filepath, failed_rows)
  end

  def read
    return upload_warning unless csv_exists?

    if expired?
      remove_csv
      return upload_warning
    end

    File.read(csv_filepath)
  end

  def cleanup
    return unless csv_exists?

    log_info("Removing old failed rows CSV")
    remove_csv
  end

  private

  def csv_exists?
    File.exist?(csv_filepath)
  end

  def expired?
    csv_exists? && File.mtime(csv_filepath) < Time.current - EXPIRATION_TIME
  end

  def remove_csv
    FileUtils.rm_f(csv_filepath)
  end

  def log_info(msg)
    Rails.logger.info("User=#{user.id}, Type=#{import_type}: #{msg}")
  end

  def upload_warning
    "Please upload a #{humanised_import_type} CSV"
  end

  def max_size_warning
    "CSV too large to save for user=#{user.id}, size=#{failed_rows.bytesize}"
  end

  def csv_filepath
    Rails.root.join("tmp", import_type.to_s, filename)
  end

  def filename
    "failed_rows_userid_#{user.id}.csv"
  end

  def humanised_import_type
    I18n.t("imports.labels.#{import_type}", default: import_type.to_s.humanize.downcase)
  end
end
