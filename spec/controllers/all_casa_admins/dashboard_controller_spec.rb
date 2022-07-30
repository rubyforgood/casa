# frozen_string_literal: true

require "rails_helper"

RSpec.describe AllCasaAdmins::DashboardController, type: :controller do
  describe "show" do
    subject { get :show }

    before do
      allow(controller).to receive(:authenticate_all_casa_admin!).and_return(true)
    end

    let!(:casa_orgs) { create_list(:casa_org, 3) }

    it do
      subject
      expect(assigns(:organizations).ids).to match_array(casa_orgs.map(&:id))
    end

    it do
      subject
      expect(response).to be_successful
    end

    it "renders the index template" do
      subject
      expect(response).to render_template("show")
    end
  end
end
