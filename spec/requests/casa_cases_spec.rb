require "rails_helper"

RSpec.describe "/casa_cases", type: :request do
  let(:organization) { create(:casa_org) }
  let(:hearing_type) { create(:hearing_type) }
  let(:judge) { create(:judge) }
  let(:valid_attributes) { {case_number: "1234", transition_aged_youth: true, casa_org_id: organization.id, hearing_type_id: hearing_type.id, judge_id: judge.id} }
  let(:invalid_attributes) { {case_number: nil} }
  let(:casa_case) { create(:casa_case, casa_org: organization, case_number: "111") }

  before { sign_in user }

  describe "as an admin" do
    let(:user) { create(:casa_admin, casa_org: organization) }

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
        other_case = create(:casa_case, casa_org: other_org)

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

      it "fails across organizations" do
        other_org = create(:casa_org)
        other_case = create(:casa_case, casa_org: other_org)

        get edit_casa_case_url(other_case)
        expect(response).to be_not_found
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

        it "sets fields correctly" do
          post casa_cases_url, params: {casa_case: valid_attributes}
          casa_case = CasaCase.last
          expect(casa_case.casa_org).to eq organization
          expect(casa_case.transition_aged_youth).to be true
          expect(casa_case.hearing_type).to eq hearing_type
          expect(casa_case.judge).to eq judge
        end
      end

      it "only creates cases within user's organizations" do
        other_org = create(:casa_org)
        attributes = {
          case_number: "1234",
          transition_aged_youth: true,
          casa_org_id: other_org.id,
          hearing_type_id: hearing_type.id,
          judge_id: judge.id
        }

        expect { post casa_cases_url, params: {casa_case: attributes} }.to(
          change { [organization.casa_cases.count, other_org.casa_cases.count] }.from([0, 0]).to([1, 0])
        )
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
      let(:new_attributes) {
        {
          case_number: "12345",
          hearing_type_id: hearing_type.id,
          judge_id: judge.id
        }
      }

      context "with valid parameters" do
        it "updates the requested casa_case" do
          patch casa_case_url(casa_case), params: {casa_case: new_attributes}
          casa_case.reload
          expect(casa_case.case_number).to eq "12345"
          expect(casa_case.hearing_type).to eq hearing_type
          expect(casa_case.judge).to eq judge
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

      it "does not update across organizations" do
        other_org = create(:casa_org)
        other_casa_case = create(:casa_case, case_number: "abc", casa_org: other_org)

        expect { patch casa_case_url(other_casa_case), params: {casa_case: new_attributes} }.not_to(
          change { other_casa_case.reload.case_number }
        )
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

      it "fails across organizations" do
        other_org = create(:casa_org)
        other_casa_case = create(:casa_case, casa_org: other_org)
        delete casa_case_url(other_casa_case)
        expect(response).to be_not_found
      end
    end

    describe "PATCH /casa_cases/:id/deactivate" do
      let(:casa_case) { create(:casa_case, :active, casa_org: organization, case_number: "111") }
      let(:params) { {id: casa_case.id} }

      it "deactivates the requested casa_case" do
        patch deactivate_casa_case_path(casa_case), params: params
        casa_case.reload
        expect(casa_case.active).to eq false
      end

      it "redirects to the casa_case" do
        patch deactivate_casa_case_path(casa_case), params: params
        casa_case.reload
        expect(response).to redirect_to(edit_casa_case_path)
      end

      it "flashes success message" do
        patch deactivate_casa_case_path(casa_case), params: params
        expect(flash[:notice]).to include("Case #{casa_case.case_number} has been deactivated.")
      end

      it "fails across organizations" do
        other_org = create(:casa_org)
        other_casa_case = create(:casa_case, casa_org: other_org)

        patch deactivate_casa_case_path(other_casa_case), params: params
        expect(response).to be_not_found
      end

      context "when deactivation fails" do
        before do
          allow_any_instance_of(CasaCase).to receive(:deactivate).and_return(false)
        end

        it "does not deactivate the requested casa_case" do
          patch deactivate_casa_case_path(casa_case), params: params
          casa_case.reload
          expect(casa_case.active).to eq true
        end
      end
    end

    describe "PATCH /casa_cases/:id/reactivate" do
      let(:casa_case) { create(:casa_case, :inactive, casa_org: organization, case_number: "111") }
      let(:params) { {id: casa_case.id} }

      it "reactivates the requested casa_case" do
        patch reactivate_casa_case_path(casa_case), params: params
        casa_case.reload
        expect(casa_case.active).to eq true
      end

      it "redirects to the casa_case" do
        patch reactivate_casa_case_path(casa_case), params: params
        casa_case.reload
        expect(response).to redirect_to(edit_casa_case_path)
      end

      it "flashes success message" do
        patch reactivate_casa_case_path(casa_case), params: params
        expect(flash[:notice]).to include("Case #{casa_case.case_number} has been reactivated.")
      end

      it "fails across organizations" do
        other_org = create(:casa_org)
        other_casa_case = create(:casa_case, casa_org: other_org)

        patch reactivate_casa_case_path(other_casa_case), params: params
        expect(response).to be_not_found
      end

      context "when reactivation fails" do
        before do
          allow_any_instance_of(CasaCase).to receive(:reactivate).and_return(false)
        end

        it "does not reactivate the requested casa_case" do
          patch deactivate_casa_case_path(casa_case), params: params
          casa_case.reload
          expect(casa_case.active).to eq false
        end
      end
    end
  end

  describe "as a volunteer" do
    let(:user) { create(:volunteer, casa_org: organization) }
    let!(:case_assignment) { create(:case_assignment, volunteer: user, casa_case: casa_case) }

    describe "GET /new" do
      it "denies access and redirects elsewhere" do
        get new_casa_case_url

        expect(response).not_to be_successful
        expect(flash[:error]).to match(/you are not authorized/)
      end
    end

    describe "GET /edit" do
      it "render a successful response" do
        get edit_casa_case_url(casa_case)
        expect(response).to be_successful
      end

      it "fails across organizations" do
        other_org = create(:casa_org)
        other_case = create(:casa_case, casa_org: other_org)

        get edit_casa_case_url(other_case)
        expect(response).to be_not_found
      end
    end

    describe "PATCH /update" do
      let(:new_attributes) {
        {
          case_number: "12345",
          court_report_status: :submitted,
          hearing_type_id: hearing_type.id,
          judge_id: judge.id
        }
      }

      context "with valid parameters" do
        it "updates permitted fields" do
          patch casa_case_url(casa_case), params: {casa_case: new_attributes}
          casa_case.reload
          expect(casa_case.court_report_submitted?).to be_truthy

          # Not permitted
          expect(casa_case.case_number).to eq "111"
          expect(casa_case.hearing_type).to_not eq hearing_type
          expect(casa_case.judge).to_not eq judge
        end

        it "redirects to the casa_case" do
          patch casa_case_url(casa_case), params: {casa_case: new_attributes}
          expect(response).to redirect_to(edit_casa_case_path(casa_case))
        end
      end

      it "does not update across organizations" do
        other_org = create(:casa_org)
        other_casa_case = create(:casa_case, case_number: "abc", casa_org: other_org)

        expect { patch casa_case_url(other_casa_case), params: {casa_case: new_attributes} }.not_to(
          change { other_casa_case.reload.attributes }
        )
      end
    end

    describe "GET /index" do
      it "shows only cases assigned to user" do
        mine = create(:casa_case, casa_org: organization, case_number: SecureRandom.hex(32))
        other = create(:casa_case, casa_org: organization, case_number: SecureRandom.hex(32))

        user.casa_cases << mine

        get casa_cases_url

        expect(response).to be_successful
        expect(response.body).to include(mine.case_number)
        expect(response.body).not_to include(other.case_number)
      end
    end

    describe "PATCH /casa_cases/:id/deactivate" do
      let(:casa_case) { create(:casa_case, :active, casa_org: organization, case_number: "111") }
      let(:params) { {id: casa_case.id} }

      it "does not deactivate the requested casa_case" do
        patch deactivate_casa_case_path(casa_case), params: params
        casa_case.reload
        expect(casa_case.active).to eq true
      end
    end

    describe "PATCH /casa_cases/:id/reactivate" do
      let(:casa_case) { create(:casa_case, :inactive, casa_org: organization, case_number: "111") }
      let(:params) { {id: casa_case.id} }

      it "does not deactivate the requested casa_case" do
        patch deactivate_casa_case_path(casa_case), params: params
        casa_case.reload
        expect(casa_case.active).to eq false
      end
    end
  end

  describe "as a supervisor" do
    let(:user) { create(:supervisor, casa_org: organization) }

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

      it "fails across organizations" do
        other_org = create(:casa_org)
        other_case = create(:casa_case, casa_org: other_org)

        get edit_casa_case_url(other_case)
        expect(response).to be_not_found
      end
    end

    describe "PATCH /update" do
      let(:new_attributes) { {case_number: "12345", court_report_status: :completed} }

      context "with valid parameters" do
        it "updates fields (except case_number)" do
          patch casa_case_url(casa_case), params: {casa_case: new_attributes}
          casa_case.reload
          expect(casa_case.case_number).to eq "111"
          expect(casa_case.court_report_completed?).to be true
        end

        it "redirects to the casa_case" do
          patch casa_case_url(casa_case), params: {casa_case: new_attributes}
          expect(response).to redirect_to(edit_casa_case_path(casa_case))
        end
      end

      it "does not update across organizations" do
        other_org = create(:casa_org)
        other_casa_case = create(:casa_case, case_number: "abc", casa_org: other_org)

        expect { patch casa_case_url(other_casa_case), params: {casa_case: new_attributes} }.not_to(
          change { other_casa_case.reload.attributes }
        )
      end
    end

    describe "GET /index" do
      it "renders a successful response" do
        create(:casa_case)
        get casa_cases_url
        expect(response).to be_successful
      end
    end

    describe "PATCH /casa_cases/:id/deactivate" do
      let(:casa_case) { create(:casa_case, :active, casa_org: organization, case_number: "111") }
      let(:params) { {id: casa_case.id} }

      it "does not deactivate the requested casa_case" do
        patch deactivate_casa_case_path(casa_case), params: params
        casa_case.reload
        expect(casa_case.active).to eq true
      end
    end

    describe "PATCH /casa_cases/:id/reactivate" do
      let(:casa_case) { create(:casa_case, :inactive, casa_org: organization, case_number: "111") }
      let(:params) { {id: casa_case.id} }

      it "does not deactivate the requested casa_case" do
        patch deactivate_casa_case_path(casa_case), params: params
        casa_case.reload
        expect(casa_case.active).to eq false
      end
    end
  end
end
