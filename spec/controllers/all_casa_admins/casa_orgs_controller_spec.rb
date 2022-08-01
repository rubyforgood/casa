# frozen_string_literal: true

require "rails_helper"

RSpec.describe AllCasaAdmins::CasaOrgsController, type: :controller do
  describe "#show" do
    let!(:casa_org) { create(:casa_org) }
    let(:metrics) { instance_double(Hash) }
    subject { get :show, params: {id: casa_org.id} }
    let(:casa_org_metrics) { instance_double(AllCasaAdmins::CasaOrgMetrics) }

    before do
      allow(controller).to receive(:authenticate_all_casa_admin!).and_return(true)
      allow(AllCasaAdmins::CasaOrgMetrics).to receive(:new).and_return(casa_org_metrics)
      allow(casa_org_metrics).to receive(:metrics).and_return(metrics)
    end

    it do
      subject
      expect(assigns(:casa_org).id).to eq(casa_org.id)
      expect(assigns(:casa_org_metrics)).to eq(metrics)
    end
  end

  describe "#new" do
    before do
      allow(controller).to receive(:authenticate_all_casa_admin!).and_return(true)
    end

    subject { get :new }
    it do
      subject
      expect(assigns(:casa_org).new_record?).to be_truthy
      expect(response).to be_successful
      expect(response).to render_template("new")
    end
  end

  describe "#create" do
    let(:params) { {} }
    subject { post :create, params: params, format: :html }

    before do
      allow(controller).to receive(:authenticate_all_casa_admin!).and_return(true)
    end

    context "with valid params" do
      let!(:params) do
        {
          casa_org: {
            name: "name",
            display_name: "display_name",
            address: "address"
          }
        }
      end
      context "with html format" do
        it { expect { subject }.to change(CasaOrg, :count).by(1) }
        it "redirects to the created casa_org" do
          subject
          expect(response).to redirect_to(all_casa_admins_casa_org_path(CasaOrg.last))
          expect(flash[:notice]).to match(/CASA Organization was successfully created./)
        end
      end

      context "with json format" do
        subject { post :create, params: params, format: :json }

        it "return new object in json" do
          subject
          expect(response.content_type).to eq "application/json; charset=utf-8"
          expect(response).to be_successful
          expect(response.body).to match CasaOrg.last.to_json
        end
      end
    end

    context "with invalid params" do
      let!(:params) do
        {
          casa_org: {
            name: "",
            display_name: "",
            address: ""
          }
        }
      end

      it { expect { subject }.not_to change(CasaOrg, :count) }
    end
  end
end
