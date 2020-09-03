require "rails_helper"

RSpec.describe "/casa_cases", type: :request do
  let(:organization) { create(:casa_org) }
  let(:valid_attributes) { {case_number: "1234", transition_aged_youth: true, casa_org_id: organization.id} }
  let(:invalid_attributes) { {case_number: nil} }
  let(:casa_case) { create(:casa_case, casa_org: organization) }

  describe "as an admin" do
    before { sign_in create(:casa_admin, casa_org: organization) }

    describe "GET /index" do
      it "renders a successful response" do
        create(:casa_case)
        get casa_cases_url
        expect(response).to be_successful
      end
    end

    describe "GET /show" do
      it "renders a successful response" do
        get casa_case_url(casa_case)
        expect(response).to be_successful
      end

      it "fails across organizations" do
        other_org = create(:casa_org)
        other_case = create(:casa_admin, casa_org: other_org)

        get casa_case_url(other_case)
        expect(response).to be_not_found
      end
    end

    describe "GET /new" do
      it "renders a successful response" do
        get new_casa_case_url
        expect(response).to be_successful
      end
    end

    describe "GET /edit" do
      it "render a successful response" do
        get edit_casa_case_url(casa_case)
        expect(response).to be_successful
      end
    end

    describe "POST /create" do
      context "with valid parameters" do
        it "creates a new CasaCase" do
          expect { post casa_cases_url, params: {casa_case: valid_attributes} }.to change(
            CasaCase,
            :count
          ).by(1)
        end

        it "redirects to the created casa_case" do
          post casa_cases_url, params: {casa_case: valid_attributes}
          expect(response).to redirect_to(casa_case_url(CasaCase.last))
        end
      end

      context "with invalid parameters" do
        it "does not create a new CasaCase" do
          expect { post casa_cases_url, params: {casa_case: invalid_attributes} }.to change(
            CasaCase,
            :count
          ).by(0)
        end

        it "renders a successful response (i.e. to display the 'new' template)" do
          post casa_cases_url, params: {casa_case: invalid_attributes}
          expect(response).to be_successful
        end
      end
    end

    describe "PATCH /update" do
      context "with valid parameters" do
        let(:new_attributes) { {case_number: "12345", transition_aged_youth: false} }

        it "does not update case_number for volunteers" do
          sign_in create(:volunteer, casa_org: organization)
          casa_case = create(:casa_case, case_number: "1234", casa_org: organization)
          patch casa_case_url(casa_case), params: {casa_case: new_attributes}
          casa_case.reload
          expect(casa_case.case_number).to eq "1234"
          expect(casa_case.transition_aged_youth).to eq false
        end

        it "updates the requested casa_case" do
          patch casa_case_url(casa_case), params: {casa_case: new_attributes}
          casa_case.reload
          expect(casa_case.case_number).to eq "12345"
          expect(casa_case.transition_aged_youth).to eq false
        end

        it "redirects to the casa_case" do
          patch casa_case_url(casa_case), params: {casa_case: new_attributes}
          casa_case.reload
          expect(response).to redirect_to(edit_casa_case_path)
        end
      end

      context "with invalid parameters" do
        it "renders a successful response displaying the edit template" do
          patch casa_case_url(casa_case), params: {casa_case: invalid_attributes}
          expect(response).to be_successful
        end
      end
    end

    describe "DELETE /destroy" do
      it "destroys the requested casa_case" do
        another_case = create(:casa_case, casa_org: organization)
        expect {
          delete casa_case_url(another_case)
          expect(response).to redirect_to(casa_cases_url)
        }.to change(CasaCase, :count).by(-1)
      end

      it "redirects to the casa_cases list" do
        delete casa_case_url(casa_case)
        expect(response).to redirect_to(casa_cases_url)
      end
    end
  end

  context "as a volunteer" do
    let(:volunteer) { create(:volunteer, casa_org: organization) }

    before { sign_in volunteer }

    describe "GET /new" do
      it "denies access and redirects elsewhere" do
        get new_casa_case_url

        expect(response).not_to be_successful
        expect(flash[:error]).to match(/you are not authorized/)
      end
    end

    describe "GET index" do
      it "shows only cases assigned to user" do
        mine = create(:casa_case, casa_org: organization, case_number: SecureRandom.hex(32))
        other = create(:casa_case, casa_org: organization, case_number: SecureRandom.hex(32))

        volunteer.casa_cases << mine

        get casa_cases_url

        expect(response).to be_successful
        expect(response.body).to include(mine.case_number)
        expect(response.body).not_to include(other.case_number)
      end
    end
  end
end
