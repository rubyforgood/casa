require "open3"
require "rbconfig"

RSpec.describe "parallel coverage" do
  it "writes each worker's resultset to a separate directory" do
    coverage_paths = ["", "2", "3", "4"].map do |worker|
      env = {"RUN_SIMPLECOV" => "true", "TEST_ENV_NUMBER" => worker}
      stdout, stderr, status = Open3.capture3(env, RbConfig.ruby, "-I", "spec", "-rrspec/core", "-rspec_helper", "-e", "puts SimpleCov.coverage_path; SimpleCov.external_at_exit = true")

      expect(status.success?).to be(true), stderr
      stdout.strip
    end

    expect(coverage_paths.uniq).to eq(coverage_paths)
    expect(coverage_paths).to all(match(%r{/coverage/parallel\d*\z}))
  end
end
