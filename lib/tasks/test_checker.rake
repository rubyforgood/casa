require "amazing_print"

DENY_FILESPEC = File.join(Rails.root, ".allow_skipping_tests")
DASHED_LINE = "-" * 80

desc "Check app rb files to verify that there are corresponding spec files."
task test_checker: :environment do
  # File containing app filespecs that should not be flagged as errors for not having spec files.
  # Lines beginning with '#' are ignored.

  # Transform the object into the object's AmazingPrint representation.
  # `ai` alone will included color ANSI sequences in the output.
  # If those color sequences need to be omitted, pass `plain: true` to `ai`.
  def amazing_printize(object)
    object.ai
  end

  # @return absolute filespec of a Rails project's top level directory.
  def top_level_dir(name)
    File.absolute_path(File.join(Rails.root, name))
  end

  # @return .rb files in a directory tree, relative to the passed directory
  def ruby_files(dir)
    absolutes = Dir[File.join(dir, "**", "*.rb")]
    absolutes.map { |fspec| fspec.sub(dir + "/", "") }.sort
  end

  # @return the absolute path of the project's app directory.
  def app_dir
    @app_dir ||= top_level_dir("app")
  end

  # @return the absolute path of the project's spec directory.
  def spec_dir
    @spec_dir ||= top_level_dir("spec")
  end

  # @return the app Ruby filespecs
  def app_files
    @app_files ||= ruby_files(app_dir)
  end

  # @return the spec Ruby filespecs, with 'spec_' removed
  def spec_files
    @spec_files ||= ruby_files(spec_dir).map do |fspec|
      if fspec.include?("requests/")
        fspec.sub("requests", "controllers")
          .sub("spec.rb", "controller.rb")
      else
        fspec.sub("_spec.rb", ".rb")
      end
    end.uniq
  end

  def ignore_files
    return @ignore_files if @ignore_files
    file_lines = File.readlines(DENY_FILESPEC).map(&:chomp)
    @ignore_files = file_lines.reject { |line| /\s*#/.match(line) } # exclude comment lines
  end

  # puts "Ignore files: \n #{ignore_files.join("\n")}"
  def missing_spec_files
    @missing_spec_files ||= app_files - spec_files
  end

  def missing_and_not_denied_spec_files
    @missing_and_not_denied_spec_files ||= missing_spec_files - ignore_files
  end

  def missing_but_denied_files
    @missing_but_denied_files ||= missing_spec_files & ignore_files
  end

  def output_missing_but_denied
    percent = (100 * missing_but_denied_files.size.to_f / app_files.size)
    puts <<~TEXT

      #{DASHED_LINE}
      #{missing_but_denied_files.size} of #{app_files.size} app files (#{percent.round(1)}%) did not have a corresponding spec file
      but were listed in the deny file (#{DENY_FILESPEC}):

      #{amazing_printize(missing_but_denied_files)}
    TEXT
  end

  def output_missing_and_not_denied
    percent = (100 * missing_and_not_denied_spec_files.size.to_f / app_files.size)
    puts <<~ERROR_TXT

      #{DASHED_LINE}
      #{missing_and_not_denied_spec_files.size} of #{app_files.size} app files (#{percent.round(1)}%) did not have a corresponding spec file
      and are not in the deny list:

      #{amazing_printize(missing_and_not_denied_spec_files)}

    ERROR_TXT
  end

  if missing_and_not_denied_spec_files.any?
    output_missing_and_not_denied
    output_missing_but_denied
    abort
  end

  if missing_but_denied_files.any?
    output_missing_but_denied
  end
end
