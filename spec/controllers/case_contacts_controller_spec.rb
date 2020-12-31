require "rails_helper"

RSpec.describe CaseContactsController, type: :controller do
  let(:organization) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, :with_casa_cases, casa_org: organization) }
  let(:case_id) { volunteer.casa_cases.first.id }
  let!(:contact_type_group_one) do
    create(:contact_type_group, casa_org: organization).tap do |group|
      create(:contact_type, contact_type_group: group, name: "Attorney")
    end
  end
  let!(:contact_type_group_two) do
    create(:contact_type_group, casa_org: organization).tap do |group|
      create(:contact_type, contact_type_group: group, name: "Therapist")
    end
  end

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(volunteer)
  end

  describe "GET new" do
    context "when the case has specific contact types assigned" do
      before do
        casa_case = volunteer.casa_cases.first
        casa_case.contact_types = contact_type_group_one.contact_types
        casa_case.save
      end

      it "only assigns that contact types groups to @current_organization_groups" do
        get :new, params: {case_contact: {casa_case_id: case_id}}
        expect(assigns(:current_organization_groups)).to eq([contact_type_group_one])
      end
    end

    context "when the case does not have specific contact types assigned" do
      it "assigns all the organizations contact type groups to @current_organization_groups" do
        get :new, params: {case_contact: {casa_case_id: case_id}}
        expect(assigns(:current_organization_groups)).to eq([contact_type_group_one, contact_type_group_two])
      end
    end
  end
end
