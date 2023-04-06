require "rails_helper"

RSpec.describe PreferenceSetTableStateService do
  subject { described_class.new(user_id: user.id) }

  let(:user) { create(:user) }
  let!(:preference_set) { create(:preference_set, user: user, table_state: table_state) }

  let(:table_state) do
    {
      table_name => table_data
    }
  end
  let(:table_name) { "volunteers_table" }
  let(:table_data) do
    {"columns" => [{"visible" => true}]}
  end

  describe '#table_state' do
    before do
      create(:preference_set, user: user, table_state: {table_name => table_state})
    end

    it 'returns the table state' do
      # binding.pry
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

  describe '#update!' do
    it 'updates the table state' do
     
    end

    context 'when the update fails' do
      it 'raises an error'
    end
  end


  describe "#table_state" do
    context "when the preference set exists" do
      before do
        create(:preference_set, user: user, table_state: {table_name => table_state})
      end

      it "returns the table state" do
        # binding.pry
        expect(subject.table_state(table_name: table_name)).to eq(table_state[table_name])
      end
    end
  end

  # describe "#save_table_state" do
  #   it "saves the table state" do
  #     # binding.pry
  #     expect {
  #       subject.table_state_update!(table_state: table_state, table_name: table_name)
  #     }.to change {
  #       # user.reload.preference_set.table_state
  #       user.reload.preference_set&.table_state&.[](table_name)
  #     }.from(nil).to(table_state)
  #   end
  # end
end
