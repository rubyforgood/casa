require "rails_helper"

RSpec.describe CourtDatesHelper do
  describe "#when_do_we_have_court_dates" do
    describe "when casa case has only dates in the past" do
      let(:casa_case) { create(:casa_case, :with_past_court_date) }

      it "returns 'past'" do
        expect(helper.when_do_we_have_court_dates(casa_case)).to eq("past")
      end
    end

    describe "when casa case only has dates in the future" do
      let(:casa_case) { create(:casa_case, :with_upcoming_court_date) }

      it "returns 'future'" do
        expect(helper.when_do_we_have_court_dates(casa_case)).to eq("future")
      end
    end

    describe "when casa case has dates both in the past and future" do
      let(:casa_case) { create(:casa_case, :with_upcoming_court_date, :with_past_court_date) }

      it "returns nothing" do
        expect(helper.when_do_we_have_court_dates(casa_case)).to eq(nil)
      end
    end
  end
end
