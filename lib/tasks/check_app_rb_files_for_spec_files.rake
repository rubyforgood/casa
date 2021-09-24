desc "Check app rb files to verify that there are corresponding spec files."
task check_app_rb_files_for_spec_files: :environment do

  # @return absolute filespec of a Rails project's top level directory.
  def top_level_dir(name)
    File.absolute_path(File.join(Rails.root, name))
  end

  # @return .rb files in a directory tree, relative to the passed directory
  def ruby_files(dir)
    absolutes = Dir[File.join(dir, '**', '*.rb')]
    absolutes.map { |fspec| fspec.sub(dir + '/', '') }
  end

  # @return the absolute path of the project's app directory.
  def app_dir
    @app_dir ||= top_level_dir('app')
  end

  # @return the absolute path of the project's spec directory.
  def spec_dir
    @spec_dir ||= top_level_dir('spec')
  end

  # @return the app Ruby filespecs
  def app_files
    @app_files ||= ruby_files(app_dir)
  end

  # @return the spec Ruby filespecs, with 'spec_' removed
  def spec_files
    @spec_files ||= ruby_files(spec_dir).map do |fspec|
      fspec.sub('_spec.rb', '.rb')
    end
  end

  missing_spec_files = (app_files - spec_files).sort
  missing_size = missing_spec_files.size
  total_size = app_files.size
  percent_missing = (100 * (missing_spec_files.size.to_f) / app_files.size)
  if missing_spec_files.any?
    abort <<~ERROR_TXT

    #{missing_size} of #{total_size} app files (#{percent_missing.round(1)}%) did not have a corresponding spec file:

    #{missing_spec_files.join("\n")}

    ERROR_TXT
  end
end
