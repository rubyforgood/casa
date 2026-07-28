require "rails_helper"

RSpec.describe "acts_as_paranoid" do
  let(:currently_probably_buggy_classes_ignored) do
    %w[]
  end
  let(:allows_multiple_deleted) { "(deleted_at IS NULL)" }

  it "checks that all activerecord models using acts_as_paranoid have the deleted exclusions on unique indexes" do
    errors = []
    found_ignored_error_indexes = []
    Zeitwerk::Loader.eager_load_all
    expect(ApplicationRecord.descendants.count).to be >= 54 # make sure we are actually testing all model classes
    ApplicationRecord.descendants.each do |clazz|
      next if clazz.abstract_class?
      next unless clazz.paranoid?
      unique_indexes = ApplicationRecord.connection_pool.with_connection do |connection|
        connection.indexes(clazz.table_name).select(&:unique)
      end
      unique_indexes.each do |idx|
        next if idx.columns == ["external_id"] # it is ok for external_id to be unique
        if currently_probably_buggy_classes_ignored.include?(idx.name)
          found_ignored_error_indexes << idx.name
          next
        end
        unless idx.where&.include?(allows_multiple_deleted)
          errors << "#{idx.name} on #{clazz} uses acts_as_paranoid but has a unique index without #{allows_multiple_deleted} but it does have: #{idx.where}"
        end
      end
    end
    expect(errors).to be_empty
    expect(found_ignored_error_indexes).to match_array(currently_probably_buggy_classes_ignored)
  end
end
