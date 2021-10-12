require "rails_helper"
require File.join(Rails.root, 'db', 'migrate', '20211012180102_change_casa_cases_court_date_to_reference')

RSpec.describe ChangeCasaCasesCourtDateToReference, type: :migration do
  subject(:migration) { described_class.new }

  before do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  describe "#up" do
    context "when there are casa cases with court dates" do
      before do
        5.times {|index| create(:casa_case, court_date: index.days.from_now) }
      end

      it "creates a court date for each casa case" do
        expect(CasaCase.count).to eq 5
        expect{ migration.up }.to change(CourtDate, :count).by(5)

        CasaCase.find_each do |casa_case|
          court_date = casa_case.court_dates.first
          expect(court_date.date).to eq casa_case.court_date
          expect(court_date.hearing_type).to eq casa_case.hearing_type
          expect(court_date.judge).to eq casa_case.judge
        end
      end
    end

    context "when there are casa cases with null court dates" do
      before do
        5.times { create(:casa_case) }
      end

      it "does not create a court date for any casa case" do
        expect(CasaCase.count).to eq 5

        expect{ migration.up }.not_to change(CourtDate, :count)
      end
    end

    context "when there are casa cases that already have references to other court dates" do
      before do
        5.times do |index|
          casa_case = create(:casa_case, court_date: index.days.ago)
          2.times { |jindex| create(:court_date, casa_case: casa_case, date: jindex.weeks.ago) }
        end
      end

      it "creates a court date for each casa case" do
        expect(CasaCase.count).to eq 5
        expect(CourtDate.count).to eq 10
        expect{ migration.up }.to change(CourtDate, :count).by(5)

        CasaCase.find_each do |casa_case|
          expect(casa_case.court_dates.count).to eq 3
          expect(casa_case.court_dates.last.date).to eq casa_case.court_date
        end
      end
    end
  end
end
