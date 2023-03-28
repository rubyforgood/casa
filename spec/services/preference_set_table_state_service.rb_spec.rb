require "rails_helper"

RSpec.describe PreferenceSetTableStateService do
  let(:user) { create(:user) }
  let(:table_name) { "volunteers_table" }
  let(:table_state) { {"columns" => [{"visible" => true}]} }
  subject { described_class.new(current_user: user) }

  describe "#fetch_table_state" do
    context "when the preference set exists" do
      before do
        create(:preference_set, user: user, table_state: {table_name => table_state})
      end

      it "returns the table state" do
        expect(subject.fetch_table_state(table_name: table_name)).to eq(table_state)
      end
    end
  end

  describe "#save_table_state" do
    it "saves the table state" do
      expect {
        subject.save_table_state(table_state: table_state, table_name: table_name)
      }.to change {
        user.reload.preference_set&.table_state&.[](table_name)
      }.from(nil).to(table_state)
    end
  end
end
