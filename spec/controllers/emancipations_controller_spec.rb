require "rails_helper"

RSpec.describe EmancipationsController, type: :controller do
  let(:organization) { build(:casa_org) }
  let(:volunteer) { create(:volunteer, :with_casa_cases, casa_org: organization) }
  let(:test_case_category) { build(:casa_case_emancipation_category) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let(:casa_case_id) { casa_case.id.to_s }
  let(:params) do
    {
      casa_case_id: casa_case_id
    }
  end

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(volunteer)
  end

  describe "#show" do
    subject(:show) { get :show, params: {casa_case_id: casa_case_id, format: format} }

    before do
      allow(controller).to receive(:authorize)
      allow(controller).to receive(:verify_authorized)
    end

    context "the format is docx" do
      let(:format) { :docx }
      let(:sablon_template) { double("Sablon::Template") }
      let(:html_body) { double("EmancipationChecklistDownloadHtml", call: "<html>some html</html>") }
      let(:emancipation_checklist) { [] }
      let(:expected_context) { {case_number: casa_case.case_number, emancipation_checklist: emancipation_checklist} }
      let(:rendered_to_string_context) { "context to string" }

      before do
        allow(Sablon).to receive(:template).and_return(sablon_template)
        allow(EmancipationChecklistDownloadHtml).to receive(:new).with(casa_case, []).and_return(html_body)
        allow(Sablon).to receive(:content).with(:html, html_body.call).and_return(emancipation_checklist)
        allow(sablon_template).to receive(:render_to_string).with(expected_context, type: :docx).and_return(rendered_to_string_context)
      end

      it "will send the appropriate docx data" do
        expect(@controller).to receive(:send_data) { @controller.head :ok }
        show
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "#not_authorized" do
    subject(:show) { get :show, params: {casa_case_id: casa_case_id, format: :json} }

    before do
      allow_any_instance_of(Volunteer).to receive(:casa_org).and_return nil
    end

    it "will do redirect to the root" do
      expect(show).to redirect_to(root_url)
    end

    context "the backtrace ends in 'save'" do
      before do
        allow_any_instance_of(Organizational::UnknownOrganization).to receive(:backtrace).and_return(["", "", "save'"])
      end

      it "will render the correct json message" do
        show
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq({error: "Sorry, you are not authorized to perform this action. Did the session expire?"}.to_json)
      end
    end
  end

  describe "#save" do
    subject(:save) { post :save, params: params }

    let!(:case_assignment) { create(:case_assignment, volunteer: volunteer, active: true, casa_case: casa_case) }
    let(:check_item_action) { "" }
    let(:check_item_id) { "" }
    let(:emancipation_categories) { [] }
    let(:emancipation_options) { [] }
    let(:casa_case) do
      create(
        :casa_case,
        casa_org: organization,
        emancipation_options: emancipation_options,
        emancipation_categories: emancipation_categories
      )
    end
    let(:params) do
      {
        casa_case_id: casa_case_id,
        check_item_action: check_item_action,
        check_item_id: check_item_id
      }
    end

    context "the casa case does not exist" do
      let(:casa_case_id) { "blah" }

      it "returns the correct error response" do
        subject
        expect(response).to have_http_status(:not_found)
        expect(response.body).to eq({error: "Could not find case from id given by casa_case_id"}.to_json)
      end
    end

    context ".in_transition_age? returns true" do
      let(:casa_case) do
        create(
          :casa_case,
          casa_org: organization,
          emancipation_options: emancipation_options,
          emancipation_categories: emancipation_categories,
          birth_month_year_youth: 13.years.ago
        )
      end

      it "returns the correct error response" do
        subject
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq({error: "The current case is not marked as transitioning"}.to_json)
      end
    end

    context "add catagory action" do
      let(:emancipation_category) { create(:emancipation_category) }
      let(:check_item_id) { emancipation_category.id.to_s }
      let(:check_item_action) { "add_category" }

      it "will add the category" do
        expect(response).to have_http_status(:ok)
        expect { subject }.to change { casa_case.emancipation_categories.count }.by(1)
      end

      context "the category is already added to the case" do
        let(:emancipation_categories) { [emancipation_category] }

        it "will not add the category" do
          expect { subject }.to_not change { casa_case.emancipation_categories.count }
        end

        it "returns the correct error response" do
          subject
          expect(response).to have_http_status(:bad_request)
          expect(response.body).to eq({error: "The record already exists as an association on the case"}.to_json)
        end
      end
    end

    context "add option action" do
      let(:emancipation_option) { create(:emancipation_option) }
      let(:check_item_id) { emancipation_option.id.to_s }
      let(:check_item_action) { "add_option" }

      it "will add the option" do
        expect(response).to have_http_status(:ok)
        expect { subject }.to change { casa_case.emancipation_options.count }.by(1)
      end

      context "the option is already added to the case" do
        let(:emancipation_options) { [emancipation_option] }

        it "will not add the option" do
          expect { subject }.to_not change { casa_case.emancipation_options.count }
        end

        it "returns the correct error response" do
          subject
          expect(response).to have_http_status(:bad_request)
          expect(response.body).to eq({error: "The record already exists as an association on the case"}.to_json)
        end
      end
    end

    context "delete category action" do
      let(:emancipation_category) { create(:emancipation_category) }
      let(:check_item_id) { emancipation_category.id.to_s }
      let(:emancipation_categories) { [emancipation_category] }
      let(:check_item_action) { "delete_category" }

      it "will remove the category" do
        expect(response).to have_http_status(:ok)
        expect { subject }.to change { casa_case.emancipation_categories.count }.by(-1)
      end

      context "the category is not added added to the case" do
        let(:emancipation_categories) { [] }

        it "will not remove the category" do
          expect { subject }.to_not change { casa_case.emancipation_categories.count }
        end

        it "return an appropriate error message" do
          subject
          expect(response).to have_http_status(:bad_request)
          expect(response.body).to eq({error: "Tried to destroy an association that does not exist"}.to_json)
        end
      end
    end

    context "delete option action" do
      let(:emancipation_option) { create(:emancipation_option) }
      let(:check_item_id) { emancipation_option.id.to_s }
      let(:emancipation_options) { [emancipation_option] }
      let(:check_item_action) { "delete_option" }

      it "will remove the option" do
        expect(response).to have_http_status(:ok)
        expect { subject }.to change { casa_case.emancipation_options.count }.by(-1)
      end

      context "the option is not added added to the case" do
        let(:emancipation_options) { [] }

        it "will not remove the option" do
          expect { subject }.to_not change { casa_case.emancipation_options.count }
        end

        it "return an appropriate error message" do
          subject
          expect(response).to have_http_status(:bad_request)
          expect(response.body).to eq({error: "Tried to destroy an association that does not exist"}.to_json)
        end
      end
    end

    context "set option action" do
      let(:emancipation_option) { create(:emancipation_option) }
      let(:check_item_id) { emancipation_option.id.to_s }
      let(:check_item_action) { "set_option" }

      it "will add the emancipation option" do
        expect(response).to have_http_status(:ok)
        expect { subject }.to change { casa_case.emancipation_options.count }.by(1)
      end

      context "the option is already added to the case" do
        let(:emancipation_options) { [emancipation_option] }

        it "will not add the option" do
          expect { subject }.to_not change { casa_case.emancipation_options.count }
        end
      end
    end

    context "unknown action" do
      let(:check_item_action) { "some unrecognized action" }

      it "return an appropriate error message" do
        subject
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq({error: "Check item action: #{check_item_action} is not a supported action"}.to_json)
      end
    end
  end
end
