require "rails_helper"

RSpec.describe AllCasaAdmins::CasaOrgMetrics, type: :model do
  let(:organization) { create :casa_org }
  let(:user) { build(:all_casa_admin) }

  describe "#metrics" do
    subject { described_class.new(organization).metrics }

    context "minimal data" do
      it "shows stats" do
        expect(subject).to eq(
          {
            "Number of admins" => 0,
            "Number of supervisors" => 0,
            "Number of active volunteers" => 0,
            "Number of inactive volunteers" => 0,
            "Number of active cases" => 0,
            "Number of inactive cases" => 0,
            "Number of all case contacts including inactives" => 0,
            "Number of active supervisor to volunteer assignments" => 0,
            "Number of active case assignments" => 0
          }
        )
      end
    end

    context "with inactives" do
      let(:obj_types) {
        [
          :casa_admin,
          :supervisor,
          :volunteer,
          :casa_case,
          :case_assignment,
          :supervisor_volunteer
        ]
      }

      before do
        obj_types.each do |obj_type|
          create(obj_type, casa_org: organization)
          create(obj_type, :inactive, casa_org: organization)
        end
      end

      it "shows stats" do
        expect(subject).to eq(
          {
            "Number of active case assignments" => 1,
            "Number of active cases" => 3,
            "Number of active supervisor to volunteer assignments" => 6,
            "Number of active volunteers" => 5,
            "Number of admins" => 2,
            "Number of all case contacts including inactives" => 1,
            "Number of inactive cases" => 1,
            "Number of inactive volunteers" => 1,
            "Number of supervisors" => 4
          }
        )
      end
    end
  end
end
