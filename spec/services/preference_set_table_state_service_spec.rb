require "rails_helper"

RSpec.describe PreferenceSetTableStateService do
  subject { described_class.new(user_id: user.id) }

  let!(:user) { create(:user) }
  let(:preference_set) { user.preference_set }
  let!(:table_state) { {"volunteers_table" => {"columns" => [{"visible" => true}]}} }
  let(:table_state2) { {"columns" => [{"visible" => false}]} }
  let(:table_name) { "volunteers_table" }

  describe "#update!" do
    context "when the update is successful" do
      it "updates the table state" do
        expect {
          subject.update!(table_state: table_state2, table_name: table_name)
        }.to change {
          preference_set.reload.table_state
        }.from({}).to({table_name => table_state2})
      end
    end

    context "when the update fails" do
      before do
        allow_any_instance_of(PreferenceSet).to receive(:save!).and_raise(ActiveRecord::RecordNotSaved)
      end

      it "raises an error" do
        expect {
          subject.update!(table_state: table_state2, table_name: table_name)
        }.to raise_error(PreferenceSetTableStateService::TableStateUpdateFailed, "Failed to update table state for '#{table_name}'")
      end
    end
  end

  describe "#table_state" do
    context "when the preference set exists" do
      before do
        table_state = {"columns" => [{"visible" => true}]}
        user.preference_set.table_state["volunteers_table"] = table_state
        user.preference_set.save!
      end

      it "returns the table state" do
        expect(subject.table_state(table_name: "volunteers_table")).to eq(table_state["volunteers_table"])
      end
    end

    context "when there is no data for that table name" do
      before do
        preference_set.table_state = {}
        preference_set.save
      end

      it "returns nil" do
        expect(subject.table_state(table_name: table_name)).to eq(nil)
      end
    end
  end
end
