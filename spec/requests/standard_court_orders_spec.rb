require "rails_helper"

RSpec.describe "StandardCourtOrders", type: :request do
  let(:casa_org) { create(:casa_org) }
  let(:standard_court_order) { create(:standard_court_order, casa_org:) }
  let(:attributes) { {casa_org_id: casa_org.id} }
  let(:admin) { create(:casa_admin, casa_org: casa_org) }
  let(:supervisor) { create(:supervisor, casa_org: casa_org) }
  let(:volunteer) { create(:volunteer, casa_org: casa_org) }

  before { sign_in user }

  describe "GET /new" do
    context "when the user is an admin" do
      let(:user) { admin }

      it "renders a successful response" do
        get new_standard_court_order_url
        expect(response).to be_successful
      end
    end

    context "when the user is a supervisor" do
      let(:user) { supervisor }

      it "redirects to the root path" do
        get new_standard_court_order_url
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Sorry, you are not authorized to perform this action.")
      end
    end

    context "when the user is a volunteer" do
      let(:user) { volunteer }

      it "redirects to the root path" do
        get new_standard_court_order_url
        expect(response).to be_redirect
        expect(flash[:notice]).to eq("Sorry, you are not authorized to perform this action.")
      end
    end
  end

  describe "GET /edit" do
    context "when the user is an admin" do
      let(:user) { admin }

      it "renders a successful response" do
        get edit_standard_court_order_url(standard_court_order)
        expect(response).to be_successful
        expect(response.body).to include(standard_court_order.value)
      end
    end

    context "when the user is a supervisor" do
      let(:user) { supervisor }

      it "redirects to the root path" do
        get edit_standard_court_order_url(standard_court_order)
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Sorry, you are not authorized to perform this action.")
      end
    end

    context "when the user is a volunteer" do
      let(:user) { volunteer }

      it "redirects to the root path" do
        get edit_standard_court_order_url(standard_court_order)
        expect(response).to be_redirect
        expect(flash[:notice]).to eq("Sorry, you are not authorized to perform this action.")
      end
    end
  end

  describe "POST /create" do
    context "when the user is an admin" do
      let(:user) { admin }

      context "with valid parameters" do
        let(:attributes) do
          {
            casa_org_id: casa_org.id,
            value: "test value"
          }
        end

        it "redirects to the edit casa_org" do
          post standard_court_orders_url, params: {standard_court_order: attributes}
          expect(response).to redirect_to(edit_casa_org_path(casa_org))
          expect(flash[:notice]).to eq("Standard court order was successfully created.")
        end
      end

      context "with invalid parameters" do
        let(:attributes) { {casa_org_id: 0} }

        it "does not create a new StandardCourtOrder" do
          expect do
            post standard_court_orders_url, params: {standard_court_order: attributes}
          end.to change(StandardCourtOrder, :count).by(0)
        end

        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post standard_court_orders_url, params: {standard_court_order: attributes}
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when the user is a supervisor" do
      let(:user) { supervisor }

      it "redirects to the root path" do
        post standard_court_orders_url
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Sorry, you are not authorized to perform this action.")
      end
    end

    context "when the user is a volunteer" do
      let(:user) { volunteer }

      it "redirects to the root path" do
        post standard_court_orders_url
        expect(response).to be_redirect
        expect(flash[:notice]).to eq("Sorry, you are not authorized to perform this action.")
      end
    end
  end

  describe "PATCH /update" do
    context "when the user is an admin" do
      let(:user) { admin }

      context "with valid parameters" do
        let!(:standard_court_order) { create(:standard_court_order, casa_org:) }

        let(:new_attributes) do
          {
            casa_org_id: casa_org.id,
            value: "test value"
          }
        end

        it "redirects to the casa_org edit" do
          patch standard_court_order_url(standard_court_order), params: {standard_court_order: new_attributes}
          expect(response).to redirect_to(edit_casa_org_path(casa_org))
          expect(flash[:notice]).to eq("Standard court order was successfully updated.")
        end
      end

      context "with invalid parameters" do
        let(:attributes) { {casa_org_id: 0} }

        it "renders a response with 422 status (i.e. to display the 'edit' template)" do
          patch standard_court_order_url(standard_court_order), params: {standard_court_order: attributes}
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when the user is a supervisor" do
      let(:user) { supervisor }

      it "redirects to the root path" do
        patch standard_court_order_url(standard_court_order)
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Sorry, you are not authorized to perform this action.")
      end
    end

    context "when the user is a volunteer" do
      let(:user) { volunteer }

      it "redirects to the root path" do
        patch standard_court_order_url(standard_court_order)
        expect(response).to be_redirect
        expect(flash[:notice]).to eq("Sorry, you are not authorized to perform this action.")
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:standard_court_order) { create(:standard_court_order, casa_org: casa_org) }

    context "when the user is an admin" do
      let(:user) { admin }

      it "redirects to edit casa_org" do
        delete standard_court_order_url(standard_court_order)
        expect(response).to redirect_to(edit_casa_org_path(casa_org))
        expect(flash[:notice]).to eq("Standard court order was successfully deleted.")
      end
    end

    context "when the user is a supervisor" do
      let(:user) { supervisor }

      it "redirects to the root path" do
        delete standard_court_order_url(standard_court_order)
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Sorry, you are not authorized to perform this action.")
      end
    end

    context "when the user is a volunteer" do
      let(:user) { volunteer }

      it "redirects to the root path" do
        delete standard_court_order_url(standard_court_order)
        expect(response).to be_redirect
        expect(flash[:notice]).to eq("Sorry, you are not authorized to perform this action.")
      end
    end
  end
end
