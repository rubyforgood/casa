require "rails_helper"

RSpec.describe CaseContactsContactDates do
  before do
    travel_to Date.new(2021, 6, 1)
  end
  after { travel_back }

  describe "#contact_dates_details" do
    subject { described_class.new(interviewees).contact_dates_details }
    context "without interviewees" do
      let(:interviewees) { [] }

      it "returns an empty array" do
        expect(subject).to eq([])
      end
    end

    context "with interviewees" do
      let(:contact_type_1) { create(:contact_type, name: "Mental therapist") }
      let(:contact_type_2) { create(:contact_type, name: "Physical therapist") }
      let(:contact_type_3) { create(:contact_type, name: "Aunt") }

      let(:ccct_1) { create(:case_contact_contact_type, contact_type: contact_type_1) }
      let(:ccct_2) { create(:case_contact_contact_type, contact_type: contact_type_2) }
      let(:ccct_3) { create(:case_contact_contact_type, contact_type: contact_type_2, case_contact: create(:case_contact, occurred_at: 1.month.ago)) }
      let(:ccct_4) do
        create(
          :case_contact_contact_type,
          contact_type: contact_type_2,
          case_contact: create(
            :case_contact,
            occurred_at: 2.months.ago,
            medium_type: CaseContact::TEXT_EMAIL
          )
        )
      end
      let(:ccct_5) { create(:case_contact_contact_type, contact_type: contact_type_3, case_contact: create(:case_contact, occurred_at: 2.months.ago)) }

      let(:interviewees) { [ccct_1, ccct_2, ccct_3, ccct_4, ccct_5] }

      it "returns formatted data" do
        expect(subject).to eq([
          {dates: "6/01*",
           dates_by_medium_type: {"in-person" => "6/01*"},
           name: "Names of persons involved, starting with the child's name",
           type: "Mental therapist"},
          {dates: "4/01*, 5/01*, 6/01*",
           dates_by_medium_type: {"in-person" => "5/01*, 6/01*", "text/email" => "4/01*"},
           name: "Names of persons involved, starting with the child's name",
           type: "Physical therapist"},
          {dates: "4/01*",
           dates_by_medium_type: {"in-person" => "4/01*"},
           name: "Names of persons involved, starting with the child's name",
           type: "Aunt"}
        ])
      end
    end
  end
end
