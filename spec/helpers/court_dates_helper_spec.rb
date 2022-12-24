require "rails_helper"

RSpec.describe CourtDatesHelper do
  describe "#when_do_we_have_court_dates" do
    subject { helper.when_do_we_have_court_dates(casa_case) }

    describe "when casa case has no court dates" do
      let(:casa_case) { create(:casa_case) }

      it { expect(subject).to eq("none") }
    end

    describe "when casa case has only dates in the past" do
      let(:casa_case) { create(:casa_case, :with_past_court_date) }

      it { expect(subject).to eq("past") }
    end

    describe "when casa case only has dates in the future" do
      let(:casa_case) { create(:casa_case, :with_upcoming_court_date) }

      it { expect(subject).to eq("future") }
    end

    describe "when casa case has dates both in the past and future" do
      let(:casa_case) { create(:casa_case, :with_upcoming_court_date, :with_past_court_date) }

      it { expect(subject).to be_nil }
    end
  end
end
