require "rails_helper"

RSpec.describe PreferenceSetTableStateService do
  subject { described_class.new(user_id: user.id) }

  let(:user) { create(:user) }
  let!(:preference_set) { create(:preference_set, user: user, table_state: table_state) }
  let(:table_state) { { "volunteers_table" => { "columns" => [{"visible" => true}] }} }
  let(:table_state2) { { "volunteers_table" => { "columns" => [{"visible" => true}] }} }
  let(:table_name) { "volunteers_table" }

  describe '#update!' do
    it 'updates the table state' do
      expect {
        subject.update!(table_state: table_state2, table_name: table_name)
      }.to change {
        user.reload.preference_set&.table_state&.[](table_name)
      }.from(:table_state).to( :table_state2)
    end

    context 'when the update fails' do
      it 'raises an error' do
      end
    end
  end

  describe '#table_state' do
    before do
      create(:preference_set, user: user, table_state: {table_name => table_state})
    end

    it 'returns the table state' do
      expect(subject.table_state(table_name: table_name)).to eq(table_state[table_name])
    end
    context 'when the preference set exists' do
    end

    context 'when there is no data for that table name' do
      let(:table_state) { {} }

      it 'returns an empty hash' do 
        expect(subject.table_state(table_name: table_name)).to eq(nil)
      end
    end
  end
end