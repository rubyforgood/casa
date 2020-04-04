require "rails_helper"

RSpec.describe CaseContactPolicy::Scope, "#resolve" do
  it "returns all CaseContacts when user is admin" do
    user = create(:user, :casa_admin)
    all_case_contacts = create_list(:case_contact, 2)

    scope = CaseContactPolicy::Scope.new(user, CaseContact)

    expect(scope.resolve).to eq all_case_contacts
  end

  it "returns all of the volunteer's case contacts when user is volunteer" do
    user = create(:user, :volunteer)
    relevant_case = create(:casa_case, volunteer: user)
    irrelevant_case = create(:casa_case)

    relevant_case_contacts = create_list(:case_contact, 2, casa_case: relevant_case)
    


    #TODO add at least one of everything
    # casa_case, case_contact, 
    # case_contact current user did or didn't create
    # case_contact for casa_case the user is or isn't assigned to
    # only combination that should show is a
    #   case_contact the user did create
    #   for a casa_case the user is assigned to
    # don't show other combinations
    # 















    all_casa_cases = create_list(:casa_case, 2)

    scope = CasaCasePolicy::Scope.new(user, CasaCase)

    expect(scope.resolve).to eq []
  end
end
