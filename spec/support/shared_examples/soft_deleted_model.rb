RSpec.shared_examples_for "a soft-deleted model" do |skip_ignores_deleted_records_in_validations_check: false, skip_deleted_at_index_check: false|
  # for usage with acts_as_paranoid models

  it { is_expected.to have_db_column(:deleted_at) }

  unless skip_deleted_at_index_check
    it { is_expected.to have_db_index(:deleted_at) }
  end

  it "cannot be found, by default" do
    model ||= create(described_class_factory)
    model.destroy!
    expect(described_class.find_by(id: model.id)).to be_nil
  end

  it "returned when unscoped" do
    model ||= create(described_class_factory)
    model.destroy!
    expect(described_class.unscoped.find_by(id: model.id)).to be_present
  end

  context "uniqueness" do
    it "ignores deleted records in validations" do
      unless skip_ignores_deleted_records_in_validations_check
        obj = create(described_class_factory)
        new_obj = obj.dup
        expect(new_obj).not_to be_valid
        obj.destroy!
        expect(new_obj).to be_valid
        expect { new_obj.save! }.not_to raise_exception
      end
    end
  end
end
