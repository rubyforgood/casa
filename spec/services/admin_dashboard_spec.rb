require "rails_helper"

RSpec.describe AdminDashboard do
  subject(:dashboard) { described_class.new(organization) }

  let(:organization) { create(:casa_org) }

  describe "#active_cases" do
    let!(:casa_case) { create(:casa_case, :active, casa_org: organization) }

    it "excludes inactive cases" do
      create(:casa_case, :inactive, casa_org: organization)

      expect(dashboard.active_cases).to contain_exactly(casa_case)
    end
  end

  describe "#unassigned_cases" do
    let!(:casa_case) { create(:casa_case, :active, casa_org: organization) }

    it "includes cases with no assignments" do
      expect(dashboard.unassigned_cases).to contain_exactly(casa_case)
    end

    it "excludes cases with an active assignment" do
      create(:case_assignment, casa_case: casa_case)

      expect(dashboard.unassigned_cases).to be_empty
    end

    it "includes cases with only an inactive assignment" do
      create(:case_assignment, :inactive, casa_case: casa_case)

      expect(dashboard.unassigned_cases).to contain_exactly(casa_case)
    end
  end

  describe "#cases_needing_contact" do
    let!(:casa_case) { create(:casa_case, :active, casa_org: organization) }

    around do |example|
      travel_to(Time.zone.local(2026, 11, 1, 12)) { example.run }
    end

    let(:volunteer) { create(:volunteer, casa_org: organization) }

    it "includes cases that have never been contacted" do
      expect(dashboard.cases_needing_contact).to contain_exactly(casa_case)
    end

    it "includes cases whose last successful contact is older than the follow-up period" do
      create(:case_contact, casa_case: casa_case, creator: volunteer,
        contact_made: true, occurred_at: Date.current - (described_class::FOLLOWUP_DAYS + 1))

      expect(dashboard.cases_needing_contact).to contain_exactly(casa_case)
    end

    it "excludes cases with a recent successful contact" do
      create(:case_contact, casa_case: casa_case, creator: volunteer,
        contact_made: true, occurred_at: Date.current - 1)

      expect(dashboard.cases_needing_contact).to be_empty
    end

    it "does not require contact exactly at the follow-up period" do
      create(:case_contact, casa_case: casa_case, creator: volunteer,
        contact_made: true, occurred_at: Date.current - described_class::FOLLOWUP_DAYS)

      expect(dashboard.cases_needing_contact).to be_empty
    end

    it "includes cases with only a recent unsuccessful contact" do
      create(:case_contact, casa_case: casa_case, creator: volunteer,
        contact_made: false, occurred_at: Date.current - 1)

      expect(dashboard.cases_needing_contact).to contain_exactly(casa_case)
    end

    it "uses the most recent successful contact" do
      create(:case_contact, casa_case: casa_case, creator: volunteer,
        contact_made: true, occurred_at: Date.current - (described_class::FOLLOWUP_DAYS + 1))
      create(:case_contact, casa_case: casa_case, creator: volunteer,
        contact_made: true, occurred_at: Date.current - 1)

      expect(dashboard.cases_needing_contact).to be_empty
    end
  end

  describe "#needs_attention" do
    it "limits unassigned cases in case number order" do
      cases = (1..(described_class::ATTENTION_LIMIT + 1)).to_a.reverse.map do |number|
        create(:casa_case, :active, casa_org: organization, case_number: "CINA-#{number}")
      end

      expected = cases.sort_by(&:case_number).first(described_class::ATTENTION_LIMIT)
      expect(dashboard.needs_attention).to eq(expected)
    end
  end

  describe "organization scoping" do
    let!(:casa_case) { create(:casa_case, :active, casa_org: organization) }

    %i[active_cases unassigned_cases cases_needing_contact needs_attention].each do |method|
      it "excludes another organization's unassigned, uncontacted cases from ##{method}" do
        create(:casa_case, :active, casa_org: create(:casa_org))

        expect(dashboard.public_send(method)).to contain_exactly(casa_case)
      end
    end
  end
end
