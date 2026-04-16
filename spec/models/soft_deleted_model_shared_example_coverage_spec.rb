require "rails_helper"

RSpec.describe "soft-deleted model shared example coverage" do
  let(:skip_classes) do
    %w[]
  end

  let(:todo_currently_missing_specs) do
    %w[
      ContactTopicAnswer
      CaseContact
    ]
  end

  it "checks that all acts_as_paranoid models have specs that include the soft-deleted model shared example" do
    missing = []
    Zeitwerk::Loader.eager_load_all

    ApplicationRecord.descendants.each do |clazz|
      next if clazz.abstract_class?
      next unless clazz.paranoid?
      next if skip_classes.include?(clazz.name)
      next if todo_currently_missing_specs.include?(clazz.name)

      source_file = Object.const_source_location(clazz.name)&.first
      next unless source_file

      spec_file = source_file.
        sub(%r{/app/models/}, "/spec/models/").
        sub(/\.rb$/, "_spec.rb")

      unless File.exist?(spec_file)
        missing << "#{clazz.name}: spec file not found (expected #{spec_file})"
        next
      end

      contents = File.read(spec_file)
      unless contents.include?('"a soft-deleted model"')
        missing << clazz.name.to_s
      end
    end

    expect(missing).to be_empty, "The following paranoid models are missing the shared example:\n#{missing.join("\n")}"
  end
end
