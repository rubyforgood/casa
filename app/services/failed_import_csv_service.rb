require "digest"

class FailedImportCsvService
  attr_accessor :failed_rows
  attr_reader :import_type, :user, :csv_filepath

  MAX_FILE_SIZE_BYTES = 250.kilobytes
  EXPIRATION_TIME = 24.hours

  def initialize(import_type:, user:, failed_rows: "", filepath: nil)
    @failed_rows = failed_rows
    @import_type = import_type
    @user = user
    @csv_filepath = filepath || generate_filepath
  end

  def store
    if failed_rows.bytesize > MAX_FILE_SIZE_BYTES
      Rails.logger.warn("CSV too large to save for user=#{user.id}, size=#{failed_rows.bytesize}")
      @failed_rows = max_size_warning
    end

    FileUtils.mkdir_p(File.dirname(csv_filepath))
    File.write(csv_filepath, failed_rows)
  end

  def read
    return exists_warning unless csv_exists?

    if expired?
      remove_csv
      return expired_warning
    end

    File.read(csv_filepath)
  end

  def cleanup
    return unless csv_exists?

    log_info("Removing old failed rows CSV")
    remove_csv
  end

  private

  def log_info(msg)
    Rails.logger.info("User=#{user.id}, Type=#{import_type}: #{msg}")
  end

  def exists_warning
    "No failed import file found. Please upload a #{humanised_import_type} CSV."
  end

  def expired_warning
    "The failed import file has expired. Please upload a new #{humanised_import_type} CSV."
  end

  def max_size_warning
    "The file was too large to save. Please make sure your CSV is smaller than 250 KB and try again."
  end

  def generate_filepath
    Pathname.new(Rails.root.join("tmp", import_type.to_s, filename)).cleanpath
  end

  def csv_exists?
    File.exist?(csv_filepath)
  end

  def expired?
    csv_exists? && File.mtime(csv_filepath) < Time.current - EXPIRATION_TIME
  end

  def remove_csv
    FileUtils.rm_f(csv_filepath)
  end

  def filename
    short_hash = Digest::SHA256.hexdigest(user.id.to_s)[0..15]
    "failed_rows_userid_#{short_hash}.csv"
  end

  def humanised_import_type
    I18n.t("imports.labels.#{import_type}", default: import_type.to_s.humanize.downcase)
  end
end
