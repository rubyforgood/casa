require "rails_helper"

RSpec.describe CaseContactsController, type: :controller do
  let(:organization) { create(:casa_org) }
  let(:user) { create(:user, casa_org: organization) }
  let(:case_contact) { create(:case_contact, creator: user, casa_case: create(:casa_case, casa_org: organization)) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "creates a new case contact and redirects to the details form" do
      get :new
      expect(response).to redirect_to(case_contact_form_path(:details, case_contact_id: assigns(:case_contact).id))
    end
  end

  describe "GET #edit" do
    it "redirects to the details form" do
      get :edit, params: { id: case_contact.id }
      expect(response).to redirect_to(case_contact_form_path(:details, case_contact_id: case_contact.id))
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested case contact" do
      case_contact # create the case contact
      expect {
        delete :destroy, params: { id: case_contact.id }
      }.to change(CaseContact, :count).by(-1)
      expect(response).to redirect_to(request.referer)
    end
  end

  describe "POST #restore" do
    it "restores the requested case contact" do
      case_contact.destroy
      post :restore, params: { id: case_contact.id }
      expect(case_contact.reload).not_to be_deleted
      expect(response).to redirect_to(request.referer)
    end
  end
end
