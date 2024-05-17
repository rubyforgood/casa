require "rails_helper"

RSpec.describe CasaCase, type: :model do
  subject { build(:casa_case) }

  it { is_expected.to have_many(:case_assignments).dependent(:destroy) }
  it { is_expected.to belong_to(:casa_org) }
  it { is_expected.to have_many(:casa_case_emancipation_categories).dependent(:destroy) }
  it { is_expected.to have_many(:emancipation_categories).through(:casa_case_emancipation_categories) }
  it { is_expected.to have_many(:casa_cases_emancipation_options).dependent(:destroy) }
  it { is_expected.to have_many(:emancipation_options).through(:casa_cases_emancipation_options) }
  it { is_expected.to validate_presence_of(:case_number) }
  it { is_expected.to validate_presence_of(:birth_month_year_youth) }
  it { is_expected.to validate_uniqueness_of(:case_number).scoped_to(:casa_org_id).case_insensitive }
  it { is_expected.to have_many(:case_court_orders).dependent(:destroy) }
  it { is_expected.to have_many(:volunteers).through(:case_assignments) }

  describe "scopes" do
    describe ".due_date_passed" do
      subject { described_class.due_date_passed }

      context "when casa_case is present" do
        let!(:court_date) { create(:court_date, date: Time.current - 3.days) }
        let(:casa_case) { court_date.casa_case }

        it { is_expected.to include(casa_case) }
      end

      context "when casa_case is not present" do
        let!(:court_date) { create(:court_date, date: Time.current + 3.days) }
        let(:casa_case) { court_date.casa_case }

        it { is_expected.not_to include(casa_case) }
      end
    end

    describe ".birthday_next_month" do
      subject { described_class.birthday_next_month }

      context "when a youth has a birthday next month" do
        let(:casa_case) { create(:casa_case, birth_month_year_youth: DateTime.now.next_month) }

        it { is_expected.to include(casa_case) }
      end

      context "when no youth has a birthday next month" do
        let(:casa_case) { create(:casa_case) }

        it { is_expected.to be_empty }
      end
    end
  end

  describe ".unassigned_volunteers" do
    let!(:casa_case) { create(:casa_case) }
    let!(:volunteer_same_org) { create(:volunteer, display_name: "Yelena Belova", casa_org: casa_case.casa_org) }
    let!(:volunteer_same_org_1_with_cases) { create(:volunteer, :with_casa_cases, display_name: "Natasha Romanoff", casa_org: casa_case.casa_org) }
    let!(:volunteer_same_org_2_with_cases) { create(:volunteer, :with_casa_cases, display_name: "Melina Vostokoff", casa_org: casa_case.casa_org) }
    let!(:volunteer_different_org) { create(:volunteer, casa_org: create(:casa_org)) }

    it "only shows volunteers for the current volunteers organization" do
      expect(casa_case.unassigned_volunteers).to include(volunteer_same_org)
      expect(casa_case.unassigned_volunteers).not_to include(volunteer_different_org)
    end

    it "sorts volunteers by display name with no cases to the top" do
      expect(casa_case.unassigned_volunteers).to contain_exactly(volunteer_same_org, volunteer_same_org_2_with_cases, volunteer_same_org_1_with_cases)
    end
  end

  describe ".ordered" do
    it "orders the casa cases by updated at date" do
      very_old_casa_case = create(:casa_case, updated_at: 5.days.ago)
      old_casa_case = create(:casa_case, updated_at: 1.day.ago)
      new_casa_case = create(:casa_case)

      ordered_casa_cases = described_class.ordered

      expect(ordered_casa_cases.map(&:id)).to eq [new_casa_case.id, old_casa_case.id, very_old_casa_case.id]
    end
  end

  describe ".actively_assigned_to" do
    it "only returns cases actively assigned to a volunteer" do
      current_user = build(:volunteer)
      inactive_case = build(:casa_case, casa_org: current_user.casa_org)
      build_stubbed(:case_assignment, casa_case: inactive_case, volunteer: current_user, active: false)
      active_cases = create_list(:casa_case, 2, casa_org: current_user.casa_org)
      active_cases.each do |casa_case|
        create(:case_assignment, casa_case: casa_case, volunteer: current_user, active: true)
      end

      other_user = build(:volunteer)
      other_active_case = build(:casa_case, casa_org: other_user.casa_org)
      other_inactive_case = build(:casa_case, casa_org: other_user.casa_org)
      create(:case_assignment, casa_case: other_active_case, volunteer: other_user, active: true)
      create(
        :case_assignment,
        casa_case: other_inactive_case, volunteer: other_user, active: false
      )

      assert_equal active_cases.map(&:case_number).sort, described_class.actively_assigned_to(current_user).map(&:case_number).sort
    end
  end

  describe ".not_assigned" do
    it "only returns cases NOT actively assigned to ANY volunteer" do
      current_user = create(:volunteer)

      never_assigned_case = create(:casa_case, casa_org: current_user.casa_org)

      inactive_case = create(:casa_case, casa_org: current_user.casa_org)
      create(:case_assignment, casa_case: inactive_case, volunteer: current_user, active: false)
      active_cases = create_list(:casa_case, 2, casa_org: current_user.casa_org)
      active_cases.each do |casa_case|
        create(:case_assignment, casa_case: casa_case, volunteer: current_user, active: true)
      end

      other_user = create(:volunteer)
      other_active_case = create(:casa_case, casa_org: other_user.casa_org)
      other_inactive_case = create(:casa_case, casa_org: other_user.casa_org)
      create(:case_assignment, casa_case: other_active_case, volunteer: other_user, active: true)
      create(
        :case_assignment,
        casa_case: other_inactive_case, volunteer: other_user, active: false
      )

      expect(described_class.not_assigned(current_user.casa_org)).to contain_exactly(never_assigned_case, inactive_case, other_inactive_case)
    end
  end

  describe ".should_transition" do
    it "returns only youth who should have transitioned but have not" do
      not_transitioned_13_yo = build(:casa_case,
        birth_month_year_youth: Date.current - 13.years)
      transitioned_14_yo = build(:casa_case,
        birth_month_year_youth: pre_transition_aged_youth_age)
      not_transitioned_14_yo = create(:casa_case,
        birth_month_year_youth: pre_transition_aged_youth_age)
      cases = CasaCase.should_transition
      aggregate_failures do
        expect(cases.length).to eq 1
        expect(cases.include?(not_transitioned_14_yo)).to eq true
        expect(cases.include?(not_transitioned_13_yo)).to eq false
        expect(cases.include?(transitioned_14_yo)).to eq false
      end
    end
  end

  describe "#active_case_assignments" do
    it "only includes active assignments" do
      casa_org = create(:casa_org)
      casa_case = create(:casa_case, casa_org: casa_org)
      case_assignments = 2.times.map { create(:case_assignment, casa_case: casa_case, volunteer: create(:volunteer, casa_org: casa_org)) }

      expect(casa_case.active_case_assignments).to match_array case_assignments

      case_assignments.first.update(active: false)
      expect(casa_case.reload.active_case_assignments).to eq [case_assignments.last]
    end
  end

  context "#add_emancipation_category" do
    let(:casa_case) { create(:casa_case) }
    let(:emancipation_category) { create(:emancipation_category) }

    it "associates an emacipation category with the case when passed the id of the category" do
      expect {
        casa_case.add_emancipation_category(emancipation_category.id)
      }.to change { casa_case.emancipation_categories.count }.from(0).to(1)
    end
  end

  context "#add_emancipation_option" do
    let(:casa_case) { create(:casa_case) }
    let(:emancipation_category) { build(:emancipation_category, mutually_exclusive: true) }
    let(:emancipation_option_a) { create(:emancipation_option, emancipation_category: emancipation_category) }
    let(:emancipation_option_b) { create(:emancipation_option, emancipation_category: emancipation_category, name: "Not the same name as option A to satisfy unique contraints") }

    it "associates an emacipation option with the case when passed the id of the option" do
      expect {
        casa_case.add_emancipation_option(emancipation_option_a.id)
      }.to change { casa_case.emancipation_options.count }.from(0).to(1)
    end

    it "raises an error when attempting to add multiple options belonging to a mutually exclusive category" do
      expect {
        casa_case.add_emancipation_option(emancipation_option_a.id)
        casa_case.add_emancipation_option(emancipation_option_b.id)
      }.to raise_error("Attempted adding multiple options belonging to a mutually exclusive category")
    end
  end

  describe "#assigned_volunteers" do
    let(:casa_org) { create(:casa_org) }
    let(:casa_case) { build(:casa_case, casa_org: casa_org) }
    let(:volunteer1) { build(:volunteer, casa_org: casa_org) }
    let(:volunteer2) { build(:volunteer, casa_org: casa_org) }
    let!(:case_assignment1) { create(:case_assignment, casa_case: casa_case, volunteer: volunteer1) }
    let!(:case_assignment2) { create(:case_assignment, casa_case: casa_case, volunteer: volunteer2) }

    it "only includes volunteers through active assignments" do
      expect(casa_case.assigned_volunteers.order(:id)).to eq [volunteer1, volunteer2].sort_by(&:id)

      case_assignment1.update(active: false)
      expect(casa_case.reload.assigned_volunteers).to eq [volunteer2]
    end

    it "only includes active volunteers" do
      expect(casa_case.assigned_volunteers.order(:id)).to eq [volunteer1, volunteer2].sort_by(&:id)

      volunteer1.update(active: false)
      expect(casa_case.reload.assigned_volunteers).to eq [volunteer2]
    end
  end

  describe "#clear_court_dates" do
    context "when court date has passed" do
      it "sets court report as unsubmitted" do
        casa_case = build(:casa_case, court_report_status: :submitted)
        casa_case.clear_court_dates

        expect(casa_case.court_report_status).to eq "not_submitted"
      end
    end
  end

  describe "#court_report_status" do
    let(:casa_case) { build(:casa_case) }
    subject { casa_case.court_report_status = court_report_status }

    let(:submitted_time) { Time.parse("Sun Nov 08 11:06:20 2020") }
    let(:the_future) { submitted_time + 2.days }
    before do
      travel_to submitted_time
    end

    after do
      travel_back
    end

    context "when the case is already submitted" do
      let(:casa_case) { build(:casa_case, court_report_status: :submitted, court_report_submitted_at: submitted_time) }
      before do
        travel_to the_future
      end

      context "when the status is completed" do
        let(:court_report_status) { :completed }

        it "completes the court report and does not update time" do
          is_expected.to eq :completed
          expect(casa_case.court_report_submitted_at).to eq(submitted_time)
        end
      end

      context "when the status is not_submitted" do
        let(:court_report_status) { :not_submitted }

        it "clears submission date and value" do
          is_expected.to eq :not_submitted
          expect(casa_case.court_report_submitted_at).to be_nil
        end
      end
    end

    context "when status is submitted" do
      let(:court_report_status) { :submitted }

      it "tracks the court report submission" do
        is_expected.to eq :submitted
        expect(casa_case.court_report_submitted_at).to eq(submitted_time)
      end
    end

    context "when the status is in review" do
      let(:court_report_status) { :in_review }

      it "tracks the court report submission" do
        is_expected.to eq :in_review
        expect(casa_case.court_report_submitted_at).to eq(submitted_time)
      end
    end
  end

  describe "#most_recent_past_court_date" do
    let(:casa_case) { create(:casa_case) }

    it "returns the latest past court date" do
      most_recent_past_court_date = create(:court_date, date: 3.months.ago)

      casa_case.court_dates << create(:court_date, date: 9.months.ago)
      casa_case.court_dates << most_recent_past_court_date
      casa_case.court_dates << create(:court_date, date: 15.months.ago)

      expect(casa_case.most_recent_past_court_date).to eq(most_recent_past_court_date)
    end
  end

  describe "#formatted_latest_court_date" do
    let(:casa_case) { create(:casa_case) }

    before do
      travel_to Date.new(2021, 1, 1)
    end

    context "with a past court date" do
      it "returns the latest past court date as a formatted string" do
        most_recent_past_court_date = create(:court_date, date: 3.months.ago)

        casa_case.court_dates << create(:court_date, date: 9.months.ago)
        casa_case.court_dates << most_recent_past_court_date
        casa_case.court_dates << create(:court_date, date: 15.months.ago)

        expect(casa_case.formatted_latest_court_date).to eq("October 01, 2020") # 3 months before 1/1/21
      end
    end

    context "without a past court date" do
      it "returns the current day as a formatted string" do
        allow(casa_case).to receive(:most_recent_past_court_date).and_return(nil)

        expect(casa_case.formatted_latest_court_date).to eq("January 01, 2021")
      end
    end
  end

  context "#remove_emancipation_category" do
    let(:casa_case) { create(:casa_case) }
    let(:emancipation_category) { build(:emancipation_category) }

    it "dissociates an emancipation category with the case when passed the id of the category" do
      casa_case.emancipation_categories << emancipation_category

      expect {
        casa_case.remove_emancipation_category(emancipation_category.id)
      }.to change { casa_case.emancipation_categories.count }.from(1).to(0)
    end
  end

  context "#remove_emancipation_option" do
    let(:casa_case) { create(:casa_case) }
    let(:emancipation_option) { build(:emancipation_option) }

    it "dissociates an emancipation option with the case when passed the id of the option" do
      casa_case.emancipation_options << emancipation_option

      expect {
        casa_case.remove_emancipation_option(emancipation_option.id)
      }.to change { casa_case.emancipation_options.count }.from(1).to(0)
    end
  end

  describe "#update_cleaning_contact_types" do
    it "cleans up contact types before saving" do
      group = build(:contact_type_group)
      type1 = build(:contact_type, contact_type_group: group)
      type2 = create(:contact_type, contact_type_group: group)

      casa_case = create(:casa_case, contact_types: [type1])

      expect(casa_case.casa_case_contact_types.count).to be 1
      expect(casa_case.contact_types).to match_array([type1])

      casa_case.update_cleaning_contact_types({casa_case_contact_types_attributes: [{contact_type_id: type2.id}]})

      expect(casa_case.casa_case_contact_types.count).to be 1
      expect(casa_case.contact_types.reload).to match_array([type2])
    end
  end

  describe "report submission" do
    let(:bad_case) { build(:casa_case) }
    # Creating a case whith a status other than not_submitted and a nil submission date
    it "rejects cases with a court report status, but no submission date" do
      bad_case.court_report_status = :in_review
      bad_case.court_report_submitted_at = nil
      bad_case.valid?

      expect(bad_case.errors[:court_report_status]).to include(
        "Court report submission date can't be nil if status is anything but not_submitted."
      )
    end

    it "rejects cases with a submission date, but no status" do
      bad_case.court_report_status = :not_submitted
      bad_case.court_report_submitted_at = DateTime.now
      bad_case.valid?

      expect(bad_case.errors[:court_report_submitted_at]).to include(
        "Submission date must be nil if court report status is not submitted."
      )
    end
  end

  describe "slug" do
    let(:casa_case) { create(:casa_case, case_number: "CINA-21-1234") }
    it "should be parameterized from the case number" do
      expect(casa_case.slug).to eq "cina-21-1234"
    end

    it "should update when the case number changes" do
      casa_case.case_number = "CINA-21-1234-changed"
      casa_case.save
      expect(casa_case.slug).to eq "cina-21-1234-changed"
    end
  end
end
