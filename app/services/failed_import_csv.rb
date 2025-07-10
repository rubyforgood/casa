class FailedImportCsv
  require "csv"

  attr_reader :failed_rows, :import_type, :user
  attr_writer :failed_rows
  private :failed_rows, :import_type, :user

  MAX_FILE_SIZE_BYTES = 1.megabyte
  EXPIRATION_TIME = 24.hours

  def initialize(import_type:, user:, failed_rows: "")
    @failed_rows = failed_rows
    @import_type = import_type
    @user = user
  end

  def cleanup
    return unless File.exist?(csv_filepath)

    Rails.logger.info("Removing old failed CSV for user=#{user.id}, type=#{import_type}")
    FileUtils.rm_f(csv_filepath)
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
    cleanup_if_expired
    return File.read(csv_filepath) if File.exist?(csv_filepath)

    Rails.logger.warn("Missing failed CSV file for user=#{user.id}, type=#{import_type}")
    "Please upload a #{humanised_import_type} CSV"
  end

  private

  def cleanup_if_expired
    return unless expired?

    FileUtils.rm_f(csv_filepath)
  end

  def expired?
    File.exist?(csv_filepath) && File.mtime(csv_filepath) < EXPIRATION_TIME.ago
  end

  def max_size_warning
    "CSV too large to save for user=#{user.id}, size=#{failed_rows.bytesize}"
  end

  def csv_filepath
    Rails.root.join("tmp", import_type, "failed_rows_userid_#{user.id}.csv")
  end

  def humanised_import_type
    I18n.t("imports.labels.#{import_type}", default: import_type.to_s.humanize.downcase)
  end
end
