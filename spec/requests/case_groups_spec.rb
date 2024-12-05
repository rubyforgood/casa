require "rails_helper"

RSpec.describe "/case_groups", type: :request do
  let(:casa_org) { create :casa_org }
  let(:supervisor) { create :supervisor, casa_org: }
  let(:user) { supervisor }

  let(:casa_cases) { create_list :casa_case, 2, casa_org: }
  let(:case_group) { create :case_group, casa_org:, casa_cases: }
  let(:valid_attributes) { attributes_for :case_group, casa_org:, casa_case_ids: casa_cases.map(&:id) }
  let(:invalid_attributes) do
    valid_attributes.merge(name: nil, casa_case_ids: [])
  end

  before { sign_in user }

  describe "GET /index" do
    subject { get case_groups_path }

    let!(:case_groups) { create_list :case_group, 2, casa_org: }

    it "renders a successful response" do
      subject
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
    end

    it "displays information of the records" do
      subject
      expect(response.body).to include(*case_groups.map(&:name))
    end
  end

  describe "GET /new" do
    subject { get new_case_group_path }

    it "renders a successful response" do
      subject
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
    end
  end

  describe "POST /create" do
    subject { post case_groups_path, params: }

    let(:params) { {case_group: valid_attributes} }

    it "creates new record" do
      expect { subject }.to change(CaseGroup, :count).by(1)
    end

    it "redirects to the case group index" do
      subject
      expect(response).to redirect_to(case_groups_path)
    end

    context "with invalid params" do
      let(:params) { {case_group: invalid_attributes} }

      it "does not create a new record" do
        expect { subject }.not_to change(CaseGroup, :count)
      end

      it "renders new template" do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET edit" do
    subject { get edit_case_group_path(case_group) }

    let(:case_group) { create :case_group, casa_org: }

    it "renders a successful response" do
      subject
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:edit)
    end
  end

  describe "PATCH /update" do
    subject { patch case_group_path(case_group), params: }

    let(:params) { {case_group: valid_attributes} }

    it "updates the requested record" do
      expect(case_group.name).not_to eq(valid_attributes[:name])
      subject
      case_group.reload
      expect(case_group.name).to eq(valid_attributes[:name])
    end

    it "redirects to the updated record" do
      subject
      expect(response).to redirect_to(case_groups_path)
    end

    context "with invalid params" do
      let(:params) { {case_group: invalid_attributes} }

      it "renders new template" do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE destroy" do
    subject { delete case_group_path(case_group) }

    let!(:case_group) { create :case_group, casa_org: }

    it "destroys the requested record" do
      expect { subject }.to change(CaseGroup, :count).by(-1)
    end

    it "redirects to the case_groups index" do
      subject
      expect(response).to redirect_to(case_groups_path)
    end
  end
end
