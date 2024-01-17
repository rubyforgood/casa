require "rails_helper"

RSpec.describe CaseContactPolicy::Scope do
  describe "#resolve" do
    it "returns all CaseContacts when user is admin" do
      user = build(:casa_admin)
      all_case_contacts = create_list(:case_contact, 2)

      scope = described_class.new(user, CaseContact)

      expect(scope.resolve).to match_array all_case_contacts
    end

    context "when user is volunteer" do
      it "returns all of the case contacts of the volunteer" do
        current_user = build(:volunteer)
        relevant_case = create(:casa_case)
        other_user = create(:volunteer)

        # we have to do a setup to test this since it's tested elsewhere
        allow(CasaCase).to receive(:actively_assigned_to)
          .and_return(CasaCase.where(id: relevant_case))

        relevant_contacts =
          create_list(:case_contact, 2, casa_case: relevant_case, creator: current_user)
        build(:case_contact, casa_case: relevant_case, creator: other_user)
        create_irrelevant_contacts(current_user, other_user)

        scope = described_class.new(current_user, CaseContact)
        aggregate_failures do
          expect(scope.resolve.include?(relevant_contacts[0])).to eq true
          expect(scope.resolve.include?(relevant_contacts[1])).to eq true
          expect(scope.resolve.length).to eq 2
        end
      end
    end

    def create_irrelevant_contacts(current_user, other_user)
      irrelevant_case = create(:casa_case)

      create_list(:case_contact, 2, casa_case: irrelevant_case, creator: current_user)
      build(:case_contact, casa_case: irrelevant_case, creator: other_user)
    end
  end
end
