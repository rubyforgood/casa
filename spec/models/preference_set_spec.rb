require "rails_helper"

RSpec.describe PreferenceSet, type: :model do
  let(:preference_set) { PreferenceSet.create(params) }

  describe "allows setting values for case_volunteer_columns" do
    let(:params) do
      {
        case_volunteer_columns: {
          case_number: "show",
          hearing_type_name: "hide",
          judge_name: "show",
          status: "show",
          transition_aged_youth: "show",
          assigned_to: "show",
          actions: "hide"
        }
      }
    end

    it { expect(preference_set.case_volunteer_columns["case_number"]).to eq "show" }
    it { expect(preference_set.case_volunteer_columns["hearing_type_name"]).to eq "hide" }
    it { expect(preference_set.case_volunteer_columns["judge_name"]).to eq "show" }
    it { expect(preference_set.case_volunteer_columns["status"]).to eq "show" }
    it { expect(preference_set.case_volunteer_columns["transition_aged_youth"]).to eq "show" }
    it { expect(preference_set.case_volunteer_columns["assigned_to"]).to eq "show" }
    it { expect(preference_set.case_volunteer_columns["actions"]).to eq "hide" }
  end
end
