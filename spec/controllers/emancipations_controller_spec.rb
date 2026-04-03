require "rails_helper"

RSpec.describe EmancipationsController, type: :controller do
  let(:organization) { create(:casa_org) }
  let(:other_org) { create(:casa_org) }
  let(:user) { create(:supervisor, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization, birth_month_year_youth: 20.years.ago) }
  let(:non_transition_case) { create(:casa_case, :pre_transition, casa_org: organization) }
  let(:emancipation_category) { create(:emancipation_category) }
  let(:emancipation_option) { create(:emancipation_option, emancipation_category: emancipation_category) }

  before { sign_in user }

  describe "GET #show" do
    context "when authenticated and authorized" do
      it "returns http success" do
        get :show, params: {casa_case_id: casa_case.friendly_id}
        expect(response).to have_http_status(:success)
      end

      it "assigns @current_case" do
        get :show, params: {casa_case_id: casa_case.friendly_id}
        expect(assigns(:current_case)).to eq(casa_case)
      end

      it "assigns @emancipation_form_data with all categories" do
        get :show, params: {casa_case_id: casa_case.friendly_id}
        expect(assigns(:emancipation_form_data)).to match_array(EmancipationCategory.all)
      end
    end

    context "when case does not exist" do
      it "raises a record not found error" do
        expect {
          get :show, params: {casa_case_id: "nonexistent-case"}
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when user belongs to a different org" do
      let(:user) { create(:supervisor, casa_org: other_org) }

      it "redirects to root with an authorization notice" do
        get :show, params: {casa_case_id: casa_case.friendly_id}
        expect(response).to redirect_to(root_url)
        expect(flash[:notice]).to match(/not authorized/)
      end
    end

    context "docx format" do
      it "sends a docx file with the correct filename" do
        get :show, params: {casa_case_id: casa_case.friendly_id}, format: :docx
        expect(response.headers["Content-Disposition"]).to include(
          "#{casa_case.case_number} Emancipation Checklist.docx"
        )
      end
    end
  end

  describe "POST #save" do
    def post_save(action, check_item_id, case_id: casa_case.friendly_id)
      post :save, params: {
        casa_case_id: case_id,
        check_item_action: action,
        check_item_id: check_item_id
      }, format: :json
    end

    # Authorization
    context "when user belongs to a different org" do
      let(:user) { create(:supervisor, casa_org: other_org) }

      it "returns unauthorized with a json error message" do
        post_save("add_category", emancipation_category.id)
        expect(response).to have_http_status(:unauthorized)
        expect(json_response["error"]).to match(/not authorized/)
      end
    end

    # Case not found
    context "when casa_case_id does not match any case" do
      it "returns 404 with a descriptive error" do
        post_save("add_category", emancipation_category.id, case_id: "nonexistent-id")
        expect(response).to have_http_status(:not_found)
        expect(json_response["error"]).to match(/Could not find case/)
      end
    end

    # Non-transitioning case
    context "when the case is not in transition age" do
      it "returns bad_request" do
        post_save("add_category", emancipation_category.id, case_id: non_transition_case.friendly_id)
        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to match(/not marked as transitioning/)
      end
    end

    # Unsupported action
    context "when check_item_action is not supported" do
      it "returns bad_request with unsupported action message" do
        post_save("unsupported_action", emancipation_category.id)
        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to match(/not a supported action/)
      end
    end

    # ADD_CATEGORY
    context "with action: add_category" do
      it "adds the category to the case and returns success" do
        expect {
          post_save("add_category", emancipation_category.id)
        }.to change { casa_case.emancipation_categories.count }.by(1)

        expect(response).to have_http_status(:ok)
        expect(json_response).to eq("success")
      end

      it "returns bad_request when category is already associated" do
        casa_case.add_emancipation_category(emancipation_category.id)
        post_save("add_category", emancipation_category.id)
        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to match(/already exists/)
      end

      it "returns bad_request when category id does not exist" do
        post_save("add_category", -1)
        expect(response).to have_http_status(:bad_request)
      end
    end

    # ADD_OPTION
    context "with action: add_option" do
      it "adds the option to the case and returns success" do
        expect {
          post_save("add_option", emancipation_option.id)
        }.to change { casa_case.emancipation_options.count }.by(1)

        expect(response).to have_http_status(:ok)
        expect(json_response).to eq("success")
      end

      it "returns bad_request when option is already associated" do
        casa_case.add_emancipation_option(emancipation_option.id)
        post_save("add_option", emancipation_option.id)
        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to match(/already exists/)
      end

      it "returns bad_request when option id does not exist" do
        post_save("add_option", -1)
        expect(response).to have_http_status(:bad_request)
      end
    end

    # DELETE_CATEGORY
    context "with action: delete_category" do
      before do
        casa_case.add_emancipation_category(emancipation_category.id)
        casa_case.add_emancipation_option(emancipation_option.id)
      end

      it "removes the category and its associated options from the case" do
        post_save("delete_category", emancipation_category.id)
        expect(response).to have_http_status(:ok)
        expect(json_response).to eq("success")
        expect(casa_case.reload.emancipation_categories).not_to include(emancipation_category)
        expect(casa_case.reload.emancipation_options).not_to include(emancipation_option)
      end

      it "returns bad_request when category is not associated with the case" do
        other_category = create(:emancipation_category)
        post_save("delete_category", other_category.id)
        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to match(/does not exist/)
      end
    end

    # DELETE_OPTION
    context "with action: delete_option" do
      before { casa_case.add_emancipation_option(emancipation_option.id) }

      it "removes the option from the case and returns success" do
        expect {
          post_save("delete_option", emancipation_option.id)
        }.to change { casa_case.emancipation_options.count }.by(-1)

        expect(response).to have_http_status(:ok)
        expect(json_response).to eq("success")
      end

      it "returns bad_request when option is not associated with the case" do
        other_option = create(:emancipation_option, emancipation_category: emancipation_category)
        post_save("delete_option", other_option.id)
        expect(response).to have_http_status(:bad_request)
        expect(json_response["error"]).to match(/does not exist/)
      end
    end

    # SET_OPTION
    context "with action: set_option" do
      let(:other_option) { create(:emancipation_option, emancipation_category: emancipation_category) }

      before { casa_case.add_emancipation_option(other_option.id) }

      it "replaces the existing option in the same category with the new one" do
        post_save("set_option", emancipation_option.id)
        expect(response).to have_http_status(:ok)
        expect(json_response).to eq("success")
        expect(casa_case.reload.emancipation_options).to include(emancipation_option)
        expect(casa_case.reload.emancipation_options).not_to include(other_option)
      end

      it "returns bad_request when option id does not exist" do
        post_save("set_option", -1)
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  # JSON error handler for unauthorized access from save
  describe "#not_authorized" do
    let(:user) { create(:supervisor, casa_org: other_org) }

    it "renders a json unauthorized error when called from save" do
      post :save, params: {
        casa_case_id: casa_case.friendly_id,
        check_item_action: "add_category",
        check_item_id: emancipation_category.id
      }, format: :json

      expect(response).to have_http_status(:unauthorized)
      expect(json_response["error"]).to match(/not authorized/)
    end
  end

  # Helper to parse JSON responses
  def json_response
    JSON.parse(response.body)
  end
end
