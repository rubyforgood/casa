# frozen_string_literal: true

require "rails_helper"
require "sablon"

A_TIMEZONE = "America/New_York"

RSpec.describe CaseCourtReportContext, type: :model do
  let(:volunteer) { create(:volunteer, :with_casa_cases) }
  let(:path_to_template) { Rails.root.join("app", "documents", "templates", "default_report_template.docx").to_s }
  let(:path_to_report) { Rails.root.join("tmp", "test_report.docx").to_s }

  before do
    travel_to Date.new(2021, 1, 1)
  end

  describe "#context" do
    it "has the right shape" do
      date = 1.day.ago
      court_date = build(:court_date, :with_hearing_type, date: date)
      context = create(:case_court_report_context, court_date: court_date)

      allow(context).to receive(:case_details).and_return({})
      allow(context).to receive(:case_contacts).and_return([])
      allow(context).to receive(:case_orders).and_return([])
      allow(context).to receive(:org_address).and_return(nil)
      allow(context).to receive(:volunteer_info).and_return({})
      allow(context).to receive(:latest_hearing_date).and_return("")

      expected_shape = {
        created_date: "January 1, 2021",
        casa_case: {},
        case_contacts: [],
        case_court_orders: [],
        case_mandates: [],
        latest_hearing_date: "",
        org_address: nil,
        volunteer: {},
        hearing_type_name: court_date.hearing_type.name
      }

      expect(context.context).to eq(expected_shape)
    end
  end

  describe "case_orders" do
    it "returns the correct shape" do
      court_orders = [
        build(:case_court_order, text: "Court order 1", implementation_status: :unimplemented),
        build(:case_court_order, text: "Court order 2", implementation_status: :implemented)
      ]
      expected = [
        {order: "Court order 1", status: "Unimplemented"},
        {order: "Court order 2", status: "Implemented"}
      ]
      context = build_stubbed(:case_court_report_context)

      expect(context.case_orders(court_orders)).to match_array(expected)
    end
  end

  describe "org_address" do
    let(:volunteer) { create(:volunteer) }
    let(:context) { build(:case_court_report_context, volunteer: volunteer) }

    context "when volunteer and default template are provided" do
      it "returns the CASA org address" do
        path_to_template = "default_report_template.docx"
        expected_address = volunteer.casa_org.address

        expect(context.org_address(path_to_template)).to eq(expected_address)
      end
    end

    context "when volunteer is provided but not default template" do
      it "returns nil" do
        path_to_template = "some_other_template.docx"

        expect(context.org_address(path_to_template)).to be_nil
      end
    end

    context "when volunteer is not provided" do
      let(:context) { build(:case_court_report_context, volunteer: false) }

      it "returns nil" do
        path_to_template = "default_report_template.docx"
        expect(context.org_address(path_to_template)).to be_nil
      end
    end
  end

  describe "#latest_hearing_date" do
    context "when casa_case has court_dates" do
      let(:court_date) { build(:court_date, date: 2.day.ago) }
      let(:casa_case) { create(:casa_case, court_dates: [court_date]) }
      let(:instance) { build(:case_court_report_context, casa_case: casa_case) }

      it "returns the formatted date" do
        expect(instance.latest_hearing_date).to eq("December 30, 2020") # 2 days before spec default date
      end
    end

    context "when most recent past court date is nil" do
      let(:instance) { build(:case_court_report_context) }

      it "returns the placeholder string" do
        expect(instance.latest_hearing_date).to eq("___<LATEST HEARING DATE>____")
      end
    end

    context "when there are multiple hearing dates" do
      let(:casa_case_with_court_dates) {
        casa_case = create(:casa_case)

        casa_case.court_dates << build(:court_date, date: 9.months.ago)
        casa_case.court_dates << build(:court_date, date: 3.months.ago)
        casa_case.court_dates << build(:court_date, date: 15.months.ago)

        casa_case
      }

      let(:court_report_context_with_latest_hearing_date) { build(:case_court_report_context, casa_case: casa_case_with_court_dates) }

      it "sets latest_hearing_date as the latest past court date" do
        expect(court_report_context_with_latest_hearing_date.latest_hearing_date).to eq("October 1, 2020")
      end
    end
  end

  describe "#calculate_date_range" do
    context "when @time_zone is set" do
      it "converts to provided timezone" do
        context = build_context(start_date: 10.day.ago, end_date: 2.day.ago, court_date: nil, time_zone: A_TIMEZONE)
        expect(context.date_range).to eq(zone_days_ago(10)..zone_days_ago(2))
      end

      it "uses current time if end_date not provided" do
        context = build_context(start_date: 10.day.ago, end_date: nil, court_date: nil, time_zone: A_TIMEZONE)
        expect(context.date_range).to eq(zone_days_ago(10)..nil)
      end

      it "uses court date if available if no start_date" do
        context = build_context(start_date: nil, end_date: 2.day.ago, court_date: 6.day.ago, time_zone: A_TIMEZONE)
        expect(context.date_range).to eq(zone_days_ago(6)..zone_days_ago(2))
      end

      it "uses nil(includes everything) if no court date or start_date" do
        context = build_context(start_date: nil, end_date: 2.day.ago, court_date: nil, time_zone: A_TIMEZONE)

        expect(context.date_range).to eq(nil..zone_days_ago(2))
      end
    end

    context "when @time_zone is not set" do
      it "uses server time zone" do
        context = build_context(start_date: 10.day.ago, end_date: 2.day.ago, court_date: nil, time_zone: nil)
        expect(context.date_range).to eq(days_ago(10)..days_ago(2))
      end

      it "uses nil if end_date not provided" do
        context = build_context(start_date: 10.day.ago, end_date: nil, court_date: nil, time_zone: nil)
        expect(context.date_range).to eq(days_ago(10)..nil)
      end

      it "uses court date if available if no start_date" do
        context = build_context(start_date: nil, end_date: 2.day.ago, court_date: 6.day.ago, time_zone: nil)
        expect(context.date_range).to eq(days_ago(6)..days_ago(2))
      end

      it "uses nil if no court date or start_date" do
        context = build_context(start_date: nil, end_date: 2.day.ago, court_date: nil, time_zone: nil)

        expect(context.date_range).to eq(nil..days_ago(2))
      end
    end
  end

  describe "#filtered_interviewees" do
    it "filters based on date range" do
      casa_case = create(:casa_case)
      court_report_context = build(:case_court_report_context, start_date: 5.day.ago.to_s, end_date: 5.day.ago.to_s, casa_case: casa_case)

      create_list(:case_contact, 3, occurred_at: 10.day.ago, casa_case: casa_case)
      create_list(:case_contact, 3, occurred_at: 1.day.ago, casa_case: casa_case)
      included_interviewee = create(:case_contact, occurred_at: 5.day.ago, casa_case: casa_case)

      result = court_report_context.filtered_interviewees.map(&:case_contact)

      expect(result).to contain_exactly(included_interviewee)
    end

    it "filters if start of date range is nil" do
      casa_case = create(:casa_case)
      court_report_context = build(:case_court_report_context, start_date: nil, end_date: 5.day.ago.to_s, casa_case: casa_case)

      create_list(:case_contact, 3, occurred_at: 1.day.ago, casa_case: casa_case)
      interviewees = create_list(:case_contact, 3, occurred_at: 10.day.ago, casa_case: casa_case)
      interviewees.append(create(:case_contact, occurred_at: 5.day.ago, casa_case: casa_case))

      result = court_report_context.filtered_interviewees.map(&:case_contact)

      expect(result).to match_array(interviewees)
    end

    it "filters if end of date range is nil" do
      casa_case = create(:casa_case)
      court_report_context = build(:case_court_report_context, start_date: 5.day.ago.to_s, end_date: nil, casa_case: casa_case)

      create_list(:case_contact, 3, occurred_at: 10.day.ago, casa_case: casa_case)
      interviewees = create_list(:case_contact, 3, occurred_at: 1.day.ago, casa_case: casa_case)
      interviewees.append(create(:case_contact, occurred_at: 5.day.ago, casa_case: casa_case))

      result = court_report_context.filtered_interviewees.map(&:case_contact)

      expect(result).to match_array(interviewees)
    end

    it "does not filter if both start and end of date range are nil" do
      casa_case = create(:casa_case)
      court_report_context = build(:case_court_report_context, start_date: nil, end_date: nil, casa_case: casa_case)

      create_list(:case_contact, 3, occurred_at: 10.day.ago, casa_case: casa_case)
      create_list(:case_contact, 3, occurred_at: 1.day.ago, casa_case: casa_case)
      create(:case_contact, occurred_at: 5.day.ago, casa_case: casa_case)

      result = court_report_context.filtered_interviewees.map(&:case_contact)

      expect(result).to match_array(CaseContact.all)
    end

    it "returns an empty array if there are no interviewees" do
      casa_case = create(:casa_case)
      court_report_context = build(:case_court_report_context, start_date: 5.day.ago.to_s, end_date: nil, casa_case: casa_case)

      result = court_report_context.filtered_interviewees.map(&:case_contact)

      expect(result).to match_array([])
    end
  end

  describe "#context" do
    let(:court_report_context) { build(:case_court_report_context) }

    describe ":created_date" do
      it "has a created date equal to the current date" do
        expect(court_report_context.context[:created_date]).to eq("January 1, 2021")
      end
    end
  end

  describe "#volunteer_info" do
    let(:volunteer) { create(:volunteer, display_name: "Y>cy%F7v;\\].-g$", supervisor: build(:supervisor, display_name: "Mm^ED;`zg(g<Z]q")) }
    let(:context) { build(:case_court_report_context, volunteer: volunteer) }

    it "correctly transforms the info" do
      expected = {
        name: "Y>cy%F7v;\\].-g$",
        supervisor_name: "Mm^ED;`zg(g<Z]q",
        assignment_date: "January 1, 2021" # This is the default set in the spec
      }

      expect(context.volunteer_info).to eq(expected)
    end
  end
end

def build_context(start_date:, end_date:, court_date:, time_zone:)
  args = {time_zone: time_zone, start_date: start_date.to_s, end_date: end_date.to_s}

  if court_date
    court_date_object = build(:court_date, date: court_date)
    court_case = create(:casa_case, court_dates: [court_date_object])
    args[:casa_case] = court_case if court_date
  end

  build(:case_court_report_context, **args)
end

def zone_days_ago(days)
  ActiveSupport::TimeZone.new(A_TIMEZONE).now - days.days
end

def days_ago(days)
  days.days.ago
end
