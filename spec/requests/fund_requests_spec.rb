require "rails_helper"

RSpec.describe FundRequestsController, type: :request do
  describe "GET /casa_cases/:casa_id/new" do
    context "when volunteer" do
      context "when volunteer is assigned to casa case" do
        it "is successful" do
          volunteer = create(:volunteer, :with_casa_cases)
          casa_case = volunteer.casa_cases.first

          sign_in volunteer
          get new_casa_case_fund_request_path(casa_case)

          expect(response).to be_successful
        end
      end

      context "when casa case is not within organization" do
        it "redirects to root" do
          volunteer = create(:volunteer)
          casa_case = create(:casa_case, casa_org: create(:casa_org))

          sign_in volunteer
          get new_casa_case_fund_request_path(casa_case)

          expect(response).to redirect_to root_path
        end
      end
    end

    context "when supervisor" do
      context "when casa_case is within organization" do
        it "is successful" do
          org = create(:casa_org)
          supervisor = create(:supervisor, casa_org: org)
          casa_case = create(:casa_case, casa_org: org)

          sign_in supervisor
          get new_casa_case_fund_request_path(casa_case)

          expect(response).to be_successful
        end
      end

      context "when casa_case is not within organization" do
        it "redirects to root" do
          supervisor = create(:supervisor)
          casa_case = create(:casa_case, casa_org: create(:casa_org))

          sign_in supervisor
          get new_casa_case_fund_request_path(casa_case)

          expect(response).to redirect_to root_path
        end
      end
    end

    context "when admin" do
      context "when casa_case is within organization" do
        it "is successful" do
          org = create(:casa_org)
          admin = create(:casa_admin, casa_org: org)
          casa_case = create(:casa_case, casa_org: org)

          sign_in admin
          get new_casa_case_fund_request_path(casa_case)

          expect(response).to be_successful
        end
      end

      context "when casa_case is not within organization" do
        it "redirects to root" do
          admin = create(:casa_admin)
          casa_case = create(:casa_case, casa_org: create(:casa_org))

          sign_in admin
          get new_casa_case_fund_request_path(casa_case)

          expect(response).to redirect_to root_path
        end
      end
    end
  end
end
