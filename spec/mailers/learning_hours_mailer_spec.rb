require "rails_helper"

RSpec.describe LearningHoursMailer, type: :mailer do
  describe "#learning_hours_report_email" do
    let(:user) { create(:user) }
    let(:casa_org) { create(:casa_org, users: [user]) }
    let(:learning_hours) { [instance_double(LearningHour)] }
    let(:csv_data) { "dummy,csv,data" }

    before do
      allow(LearningHour).to receive(:where).and_return(learning_hours)
      allow(LearningHoursExportCsvService).to receive(:new).and_return(instance_double(LearningHoursExportCsvService, perform: csv_data))
    end

    it "sends the email to the provided user with correct subject and attachment" do
      mail = LearningHoursMailer.learning_hours_report_email(user)

      expect(mail.to).to eq([user.email])

      end_date = Date.today.end_of_month
      expected_subject = "Learning Hours Report for #{end_date.strftime("%B, %Y")}."
      expect(mail.subject).to eq(expected_subject)

      expect(mail.attachments.first.filename).to eq("learning-hours-report-#{Date.today}.csv")
      expect(mail.attachments.first.body.raw_source).to eq(csv_data)
    end

    context "when no user is provided" do
      it "does not send the email and notifies Bugsnag" do
        expect(Bugsnag).to receive(:notify)

        mail = LearningHoursMailer.learning_hours_report_email(nil)
        expect(mail.message).to be_a_kind_of(ActionMailer::Base::NullMail)
      end
    end
  end
end
