require "rails_helper"

RSpec.describe CasaCase do
  subject { build(:casa_case) }

  it { is_expected.to have_many(:case_assignments) }
  it { is_expected.to belong_to(:casa_org) }
  it { is_expected.to belong_to(:hearing_type).optional }
  it { is_expected.to belong_to(:judge).optional }
  it { is_expected.to validate_presence_of(:case_number) }
  it { is_expected.to validate_uniqueness_of(:case_number).case_insensitive }
  it { is_expected.to have_many(:volunteers).through(:case_assignments) }

  describe ".ordered" do
    it "orders the casa cases by updated at date" do
      very_old_casa_case = create(:casa_case, updated_at: 5.days.ago)
      old_casa_case = create(:casa_case, updated_at: 1.day.ago)
      new_casa_case = create(:casa_case)

      ordered_casa_cases = described_class.ordered

      expect(ordered_casa_cases).to eq [new_casa_case, old_casa_case, very_old_casa_case]
    end
  end

  describe "#should_transition" do
    it "returns only youth who should have transitioned but have not" do
      not_transitioned_13_yo = create(:casa_case,
        birth_month_year_youth: Date.current - 13.years,
        transition_aged_youth: false)
      transitioned_14_yo = create(:casa_case,
        birth_month_year_youth: Date.current - 14.years,
        transition_aged_youth: true)
      not_transitioned_14_yo = create(:casa_case,
        birth_month_year_youth: Date.current - 14.years,
        transition_aged_youth: false)
      cases = CasaCase.should_transition
      aggregate_failures do
        expect(cases.length).to eq 1
        expect(cases.include?(not_transitioned_14_yo)).to eq true
        expect(cases.include?(not_transitioned_13_yo)).to eq false
        expect(cases.include?(transitioned_14_yo)).to eq false
      end
    end
  end

  describe ".actively_assigned_to" do
    it "only returns cases actively assigned to a volunteer" do
      current_user = create(:volunteer)
      inactive_case = create(:casa_case)
      create(:case_assignment, casa_case: inactive_case, volunteer: current_user, is_active: false)
      active_cases = create_list(:casa_case, 2)
      active_cases.each do |casa_case|
        create(:case_assignment, casa_case: casa_case, volunteer: current_user, is_active: true)
      end

      other_user = create(:volunteer)
      other_active_case = create(:casa_case)
      other_inactive_case = create(:casa_case)
      create(:case_assignment, casa_case: other_active_case, volunteer: other_user, is_active: true)
      create(
        :case_assignment,
        casa_case: other_inactive_case, volunteer: other_user, is_active: false
      )

      assert_equal active_cases.map(&:case_number).sort, described_class.actively_assigned_to(current_user).map(&:case_number).sort
    end
  end

  describe ".available_for_volunteer" do
    let(:casa_org) { create(:casa_org) }
    let!(:casa_case1) { create(:casa_case, :with_case_assignments, case_number: "foo", casa_org: casa_org) }
    let!(:casa_case2) { create(:casa_case, :with_case_assignments, case_number: "bar", casa_org: casa_org) }
    let!(:casa_case3) { create(:casa_case, case_number: "baz", casa_org: casa_org) }
    let!(:casa_case4) { create(:casa_case, casa_org: create(:casa_org)) }
    let(:volunteer) { create(:volunteer, casa_org: casa_org) }

    context "when volunteer has no case assignments" do
      it "returns all cases in volunteer's organization" do
        expect(described_class.available_for_volunteer(volunteer)).to eq [casa_case2, casa_case3, casa_case1]
      end
    end

    context "when volunteer has case assignments" do
      let(:case_assignment1) { create(:case_assignment, volunteer: volunteer) }
      let(:case_assignment2) { create(:case_assignment) }
      let!(:casa_case) { create(:casa_case, case_assignments: [case_assignment1, case_assignment2], casa_org: casa_org) }

      it "returns cases to which volunteer is not assigned in same org" do
        expect(described_class.available_for_volunteer(volunteer)).to eq [casa_case2, casa_case3, casa_case1]
      end
    end
  end

  context "#update_cleaning_contact_types" do
    it "cleans up contact types before saving" do
      group = create(:contact_type_group)
      type1 = create(:contact_type, contact_type_group: group)
      type2 = create(:contact_type, contact_type_group: group)

      casa_case = create(:casa_case, contact_types: [type1])

      expect(casa_case.casa_case_contact_types.count).to eql 1
      expect(casa_case.contact_types).to match_array([type1])

      casa_case.update_cleaning_contact_types({casa_case_contact_types_attributes: [{contact_type_id: type2.id}]})

      expect(casa_case.casa_case_contact_types.count).to eql 1
      expect(casa_case.contact_types.reload).to match_array([type2])
    end
  end

  describe "#clear_court_dates" do
    context "when court date has passed" do
      it "clears court date" do
        casa_case = create(:casa_case, court_date: "2020-09-13 02:11:58")
        casa_case.clear_court_dates

        expect(casa_case.court_date).to eql nil
      end

      it "clears report due date" do
        casa_case = create(:casa_case, court_date: "2020-09-13 02:11:58", court_report_due_date: "2020-09-13 02:11:58")
        casa_case.clear_court_dates

        expect(casa_case.court_report_due_date).to eql nil
      end

      it "sets court report as unsubmitted" do
        casa_case = create(:casa_case, court_date: "2020-09-13 02:11:58", court_report_submitted: true)
        casa_case.clear_court_dates

        expect(casa_case.court_report_submitted).to eql false
      end
    end
  end
end
