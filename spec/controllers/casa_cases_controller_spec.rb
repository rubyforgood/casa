require "rails_helper"

RSpec.describe CasaCasesController, type: :controller do
  let(:organization) { create(:casa_org) }
  let(:admin) { create(:casa_admin) }
  let!(:casa_case) { create(:casa_case, casa_org: organization) }

  context "when logged in as an admin user" do
    before do
      sign_in admin
    end

    describe "#deactivate" do
      context "when request formate is json" do
        it "should deactivate the casa_case when provided valid case_id" do
          patch :deactivate, format: :json, params: {
            id: casa_case.id
          }

          expect(response.status).to eq 200
          expect(response.body).to eq "Case #{casa_case.case_number} has been deactivated."
        end

        it "should return 404 error when provided invalid case_id" do
          patch :deactivate, format: :json, params: {
            id: 123
          }
          expect(response.status).to eq 404
        end
      end

      context "when request formate is html" do
        it "should deactivate the casa_case when provided valid case_id" do
          patch :deactivate, params: {
            id: casa_case.id
          }

          expect(response.status).to eq 302
          expect(response).to redirect_to(edit_casa_case_path(casa_case))
          expect(flash[:notice]).to eq "Case #{casa_case.case_number} has been deactivated."
        end
      end
    end

    describe "#reactivate" do
      context "when request formate is json" do
        it "should reactivate the casa_case when provided valid case_id" do
          patch :reactivate, format: :json, params: {
            id: casa_case.id
          }

          expect(response.status).to eq 200
          expect(response.body).to eq "Case #{casa_case.case_number} has been reactivated."
        end

        it "should return 404 error when provided invalid case_id" do
          patch :reactivate, format: :json, params: {
            id: 123
          }
          expect(response.status).to eq 404
        end
      end

      context "when request formate is html" do
        it "should reactivate the casa_case when provided valid case_id" do
          patch :reactivate, params: {
            id: casa_case.id
          }

          expect(response.status).to eq 302
          expect(response).to redirect_to(edit_casa_case_path(casa_case))
          expect(flash[:notice]).to eq "Case #{casa_case.case_number} has been reactivated."
        end
      end
    end

    describe "POST #create" do
      let!(:contact_type) { create(:contact_type) }
      context "with valid params" do
        let(:params) {
          {
            "case_number" => "TestCase-1",
            "birth_month_year_youth(3i)" => "1",
            "birth_month_year_youth(2i)" => "3",
            "birth_month_year_youth(1i)" => "1990",
            "date_in_care(3i)" => "1",
            "date_in_care(2i)" => "2",
            "date_in_care(1i)" => "2020",
            "court_dates_attributes" => {"0" => {"date" => "2022/10/31"}},
            "court_report_status" => "submitted",
            "casa_case_contact_types_attributes" => [{"contact_type_id" => contact_type.id}]
          }
        }

        it "creates new casa case with provided case contacts" do
          expect {
            post :create, params: {casa_case: params}, format: :json
          }.to change(CasaCase, :count).by(1)
          expect(response).to have_http_status(201)
          casa_case = CasaCase.find(response.parsed_body["id"])
          expect(casa_case.contact_types.first.id).to eq(contact_type.id)
        end
      end

      context "with invalid params" do
        let(:params) {
          {
            "case_number" => "",
            "birth_month_year_youth(3i)" => "",
            "birth_month_year_youth(2i)" => "",
            "birth_month_year_youth(1i)" => "",
            "date_in_care(3i)" => "",
            "date_in_care(2i)" => "",
            "date_in_care(1i)" => "",
            "court_dates_attributes" => {"0" => {"date" => "2022/10/31"}},
            "court_report_status" => "submitted",
            "casa_case_contact_types_attributes" => [
              {"contact_type_id" => ""}
            ]
          }
        }

        it "failed to create casa case" do
          expect {
            post :create, params: {casa_case: params}, format: :json
          }.to change(CasaCase, :count).by(0)
          expect(response).to have_http_status(422)
        end
      end

      context "with invalid params, missing contact types" do
        let(:params) {
          {
            "case_number" => "TestCase-1",
            "birth_month_year_youth(3i)" => "1",
            "birth_month_year_youth(2i)" => "3",
            "birth_month_year_youth(1i)" => "1990",
            "date_in_care(3i)" => "1",
            "date_in_care(2i)" => "2",
            "date_in_care(1i)" => "2020",
            "court_dates_attributes" => {"0" => {"date" => "2022/10/31"}},
            "court_report_status" => "submitted"
          }
        }

        it "does not create a new casa case" do
          expect {
            post :create, params: {casa_case: params}, format: :json
          }.to change(CasaCase, :count).by(0)
          expect(response).to have_http_status(422)
          expect(assigns(:casa_case).errors[:casa_case_contact_types]).to include(": At least one contact type must be selected")
        end
      end
    end
  end
end
