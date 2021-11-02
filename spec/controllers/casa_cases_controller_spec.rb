require "rails_helper"

RSpec.describe CasaCasesController, type: :controller do
  let(:organization) { create(:casa_org) }
  let(:volunteer) { create(:volunteer, :with_cases_and_contacts, casa_org: organization) }

  describe "#show" do
    context "when logged in as volunteer" do
      before do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        allow(controller).to receive(:current_user).and_return(volunteer)

        get :show, params: { casa_org_slug: organization.slug, slug: case_slug, format: :csv }
      end

      context "when exporting a csv" do
        let(:case_slug) { volunteer.casa_cases.first.slug }
        let(:current_time) { Time.now.strftime("%Y-%m-%d") }
        let(:casa_case_number) { volunteer.casa_cases.first.case_number }

        it "generates a csv" do
          expect(response).to have_http_status(:ok)
          expect(response.headers["Content-Type"]).to include "text/csv"
          expect(response.headers["Content-Disposition"]).to include "#{casa_case_number}-case-contacts-#{current_time}"
        end

        it "adds the correct headers to the csv" do
          csv_headers = ["Internal Contact Number", "Duration Minutes", "Contact Types", "Contact Made", "Contact Medium", "Occurred At", "Added To System At", "Miles Driven", "Wants Driving Reimbursement", "Casa Case Number", "Creator Email", "Creator Name", "Supervisor Name", "Case Contact Notes"]

          csv_headers.each { |header| expect(response.body).to include header }
        end
      end
    end
    context "when logged in as volunteer it exports xlsx file" do
      before do
        allow(controller).to receive(:authenticate_user!).and_return(true)
        allow(controller).to receive(:current_user).and_return(volunteer)

        get :show, params: { casa_org_slug: organization.slug, slug: case_slug, format: :xlsx }
      end

      context "when exporting a xlsx" do
        let(:case_slug) { volunteer.casa_cases.first.slug }
        let(:current_time) { Time.now.strftime("%Y-%m-%d") }
        let(:casa_case_number) { volunteer.casa_cases.first.case_number }

        it "generates a xlsx file" do
          expect(response).to have_http_status(:ok)
          expect(response.headers["Content-Type"]).to include "application/vnd.openxmlformats"
          expect(response.headers["Content-Disposition"]).to include "#{casa_case_number}-case-contacts-#{current_time}"
        end
      end
    end
  end
end
