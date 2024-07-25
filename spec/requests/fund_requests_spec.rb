require "rails_helper"

RSpec.describe FundRequestsController, type: :request do
  describe "GET /casa_cases/:casa_id/fund_request/new" do
    context "when volunteer" do
      context "when casa_case is within organization" do
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

  describe "POST /casa_cases/:casa_id/fund_request" do
    context "when volunteer" do
      context "when casa_case is within organization" do
        context "with valid params" do
          it "creates fund request, calls mailer, and redirects to casa case" do
            volunteer = create(:volunteer, :with_casa_cases)
            casa_case = volunteer.casa_cases.first
            stub_const("ENV", {"FUND_REQUEST_RECIPIENT_EMAIL" => "recipient@example.com"})

            sign_in volunteer

            expect {
              post casa_case_fund_request_path(casa_case), params: {
                submitter_email: "submitter@example.com",
                youth_name: "CINA-123",
                payment_amount: "$10.00",
                deadline: "2022-12-31",
                request_purpose: "something noble",
                payee_name: "Minnie Mouse",
                requested_by_and_relationship: "Favorite Volunteer",
                other_funding_source_sought: "Some other agency",
                impact: "Great",
                extra_information: "foo bar"
              }
            }.to change(FundRequest, :count).by(1)
              .and change(ActionMailer::Base.deliveries, :count).by(1)

            fr = FundRequest.last
            expect(fr.submitter_email).to eq "submitter@example.com"
            expect(fr.youth_name).to eq "CINA-123"
            expect(fr.payment_amount).to eq "$10.00"
            expect(fr.deadline).to eq "2022-12-31"
            expect(fr.request_purpose).to eq "something noble"
            expect(fr.payee_name).to eq "Minnie Mouse"
            expect(fr.requested_by_and_relationship).to eq "Favorite Volunteer"
            expect(fr.other_funding_source_sought).to eq "Some other agency"
            expect(fr.impact).to eq "Great"
            expect(fr.extra_information).to eq "foo bar"
            expect(response).to redirect_to casa_case

            mail = ActionMailer::Base.deliveries.last
            expect(mail.subject).to eq("Fund request from submitter@example.com")
            expect(mail.to).to match_array(["recipient@example.com", "submitter@example.com"])
            expect(mail.body.encoded).to include("Youth name")
            expect(mail.body.encoded).to include("CINA-123")
            expect(mail.body.encoded).to include("Payment amount")
            expect(mail.body.encoded).to include("$10.00")
            expect(mail.body.encoded).to include("Deadline")
            expect(mail.body.encoded).to include("2022-12-31")
            expect(mail.body.encoded).to include("Request purpose")
            expect(mail.body.encoded).to include("something noble")
            expect(mail.body.encoded).to include("Payee name")
            expect(mail.body.encoded).to include("Minnie Mouse")
            expect(mail.body.encoded).to include("Requested by and relationship")
            expect(mail.body.encoded).to include("Favorite Volunteer")
            expect(mail.body.encoded).to include("Other funding source sought")
            expect(mail.body.encoded).to include("Some other agency")
            expect(mail.body.encoded).to include("Impact")
            expect(mail.body.encoded).to include("Great")
            expect(mail.body.encoded).to include("Extra information")
            expect(mail.body.encoded).to include("foo bar")
          end
        end

        context "with invalid params" do
          it "does not create fund request or call mailer" do
            volunteer = create(:volunteer, :with_casa_cases)
            casa_case = volunteer.casa_cases.first
            allow_any_instance_of(FundRequest).to receive(:save).and_return(false)

            sign_in volunteer
            expect(FundRequestMailer).to_not receive(:send_request)
            expect {
              post casa_case_fund_request_path(casa_case), params: {
                submitter_email: "foo@example.com",
                youth_name: "CINA-123",
                payment_amount: "$10.00",
                deadline: "2022-12-31",
                request_purpose: "something noble",
                payee_name: "Minnie Mouse",
                requested_by_and_relationship: "Favorite Volunteer",
                other_funding_source_sought: "Some other agency",
                impact: "Great",
                extra_information: "foo bar"
              }
            }.to_not change(FundRequest, :count)

            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context "when casa_case is not within organization" do
        it "does not create fund request or call mailer" do
          volunteer = create(:volunteer, :with_casa_cases)
          casa_case = create(:casa_case, casa_org: create(:casa_org))

          sign_in volunteer
          expect(FundRequestMailer).to_not receive(:send_request)
          expect {
            post casa_case_fund_request_path(casa_case), params: {
              submitter_email: "foo@example.com",
              youth_name: "CINA-123",
              payment_amount: "$10.00",
              deadline: "2022-12-31",
              request_purpose: "something noble",
              payee_name: "Minnie Mouse",
              requested_by_and_relationship: "Favorite Volunteer",
              other_funding_source_sought: "Some other agency",
              impact: "Great",
              extra_information: "foo bar"
            }
          }.to_not change(FundRequest, :count)

          expect(response).to redirect_to root_path
        end
      end
    end

    context "when supervisor" do
      it "creates fund request, calls mailer, and redirects to casa case" do
        supervisor = create(:supervisor)
        casa_case = create(:casa_case)
        mailer_mock = double("mailer", deliver: nil)

        sign_in supervisor

        expect(FundRequestMailer).to receive(:send_request).with(nil, instance_of(FundRequest)).and_return(mailer_mock)
        expect(mailer_mock).to receive(:deliver)
        expect {
          post casa_case_fund_request_path(casa_case), params: {
            submitter_email: "foo@example.com",
            youth_name: "CINA-123",
            payment_amount: "$10.00",
            deadline: "2022-12-31",
            request_purpose: "something noble",
            payee_name: "Minnie Mouse",
            requested_by_and_relationship: "Favorite Volunteer",
            other_funding_source_sought: "Some other agency",
            impact: "Great",
            extra_information: "foo bar"
          }
        }.to change(FundRequest, :count).by(1)

        expect(response).to redirect_to casa_case
      end
    end

    context "when admin" do
      it "creates fund request, calls mailer, and redirects to casa case" do
        admin = create(:casa_admin)
        casa_case = create(:casa_case)
        mailer_mock = double("mailer", deliver: nil)

        sign_in admin

        expect(FundRequestMailer).to receive(:send_request).with(nil, instance_of(FundRequest)).and_return(mailer_mock)
        expect(mailer_mock).to receive(:deliver)
        expect {
          post casa_case_fund_request_path(casa_case), params: {
            submitter_email: "foo@example.com",
            youth_name: "CINA-123",
            payment_amount: "$10.00",
            deadline: "2022-12-31",
            request_purpose: "something noble",
            payee_name: "Minnie Mouse",
            requested_by_and_relationship: "Favorite Volunteer",
            other_funding_source_sought: "Some other agency",
            impact: "Great",
            extra_information: "foo bar"
          }
        }.to change(FundRequest, :count).by(1)

        expect(response).to redirect_to casa_case
      end
    end
  end
end
