require "rails_helper"

RSpec.describe CaseContactPolicy::Scope, "#resolve" do
  it "returns all CaseContacts when user is admin" do
    user = create(:user, :casa_admin)
    all_case_contacts = create_list(:case_contact, 2)

    scope = CaseContactPolicy::Scope.new(user, CaseContact)

    expect(scope.resolve).to eq all_case_contacts
  end

  it "returns all of the volunteer's case contacts when user is volunteer" do
    current_user = create(:user, :volunteer)
    other_user = create(:user, :volunteer)
    relevant_case = create(:casa_case)
    irrelevant_case = create(:casa_case)

    # we have to do a setup to test this since it's tested elsewhere
    expect(CasaCase).to receive(:actively_assigned_to).and_return(CasaCase.where(id: relevant_case))

    relevant_contacts = create_list(:case_contact, 2,
                                    casa_case: relevant_case,
                                    creator: current_user)
    other_user_contact = create(:case_contact,
                                casa_case: relevant_case,
                                creator: other_user)

    irrelevant_contacts = create_list(:case_contact, 2,
                                      casa_case: irrelevant_case,
                                      creator: current_user)
    other_user_irrelevant_contacts = create(:case_contact,
                                            casa_case: irrelevant_case,
                                            creator: other_user)

    scope = CaseContactPolicy::Scope.new(current_user, CaseContact)
    expect(scope.resolve).to eq relevant_contacts
  end
end
