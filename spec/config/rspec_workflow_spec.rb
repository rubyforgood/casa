require "yaml"

RSpec.describe "RSpec CI workflow" do
  let(:workflow) { YAML.load_file(File.expand_path("../../.github/workflows/rspec.yml", __dir__)) }
  let(:steps) { workflow.fetch("jobs").fetch("rspec").fetch("steps") }

  it "prepares four test databases and runs the suite in four processes" do
    build = steps.find { |step| step["name"] == "Build App" }.fetch("run")
    rspec = steps.find { |step| step["name"] == "Run rspec" }.fetch("run")

    expect(build).to include("parallel:create", "parallel:load_schema")
    expect(rspec).to include("parallel_test spec --type rspec -n 4")
  end

  it "restores runtime data for balanced test groups" do
    cache = steps.find { |step| step["uses"]&.start_with?("actions/cache@") }
    rspec = steps.find { |step| step["name"] == "Run rspec" }.fetch("run")

    expect(cache).not_to be_nil
    expect(cache.fetch("with").fetch("path")).to eq("tmp/parallel_runtime_rspec.log")
    expect(cache.fetch("with").fetch("restore-keys")).to include("parallel-runtime-")
    expect(cache.fetch("with").fetch("key")).to include("github.run_attempt")
    expect(rspec).to include("group_by=runtime", '--group-by "$group_by"')
  end

  it "combines separate worker runtime logs for the next run" do
    options = File.read(File.expand_path("../../.rspec_parallel", __dir__))
    combine = steps.find { |step| step["name"] == "Combine runtime logs" }

    expect(options).to include('RuntimeLogger --out tmp/parallel_runtime_rspec_worker<%= ENV["TEST_ENV_NUMBER"] %>.log')
    expect(combine).not_to be_nil
    expect(combine.fetch("run")).to include("parallel_runtime_rspec_worker*.log", "parallel_runtime_rspec.log")
  end

  it "collates coverage before uploading it" do
    merge_index = steps.index { |step| step["name"] == "Merge coverage" }
    upload_index = steps.index { |step| step["uses"]&.start_with?("qltysh/qlty-action/coverage@") }

    expect(merge_index).not_to be_nil
    expect(merge_index).to be < upload_index
    expect(steps.fetch(merge_index).fetch("run")).to include("SimpleCov.collate")
  end

  it "loads spec_helper in parallel workers" do
    options = File.read(File.expand_path("../../.rspec_parallel", __dir__))

    expect(options).to include("--require spec_helper")
  end
end
