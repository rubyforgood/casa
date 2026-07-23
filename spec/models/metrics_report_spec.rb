require "rails_helper"

RSpec.describe MetricsReport do
  describe ".clamp_range" do
    it "accepts the allowed presets" do
      expect(described_class.clamp_range("3")).to eq(3)
      expect(described_class.clamp_range(6)).to eq(6)
      expect(described_class.clamp_range("12")).to eq(12)
    end

    it "falls back to 12 months for anything else" do
      expect(described_class.clamp_range("999")).to eq(12)
      expect(described_class.clamp_range(nil)).to eq(12)
      expect(described_class.clamp_range("")).to eq(12)
    end
  end

  describe "org scoping (multi-tenancy)" do
    let(:org_a) { create(:casa_org) }
    let(:org_b) { create(:casa_org) }
    let(:vol_a) { create(:volunteer, casa_org: org_a) }
    let(:vol_b) { create(:volunteer, casa_org: org_b) }

    before do
      3.times { create(:case_contact, :active, casa_case: create(:casa_case, casa_org: org_a), creator: vol_a, created_at: Time.current, notes: "note") }
      create(:case_contact, :active, casa_case: create(:casa_case, casa_org: org_b), creator: vol_b, created_at: Time.current, notes: "note")
    end

    it "counts every chapter's contacts when unscoped" do
      expect(described_class.new.monthly_case_contacts(3)[:series][0][:data].last).to eq(4)
    end

    it "counts only the given chapter's contacts when scoped" do
      expect(described_class.new(casa_org: org_a).monthly_case_contacts(3)[:series][0][:data].last).to eq(3)
      expect(described_class.new(casa_org: org_b).monthly_case_contacts(3)[:series][0][:data].last).to eq(1)
    end

    it "does not leak another chapter's contacts into the heatmap" do
      expect(described_class.new(casa_org: org_a).contact_creation_heatmap(3)[:max]).to eq(3)
      expect(described_class.new(casa_org: org_b).contact_creation_heatmap(3)[:max]).to eq(1)
    end
  end

  describe "#contacts_this_month / #contacts_previous_month" do
    let(:org) { create(:casa_org) }
    let(:kase) { create(:casa_case, casa_org: org) }

    it "counts contacts by created_at within each calendar month, scoped to the org" do
      create(:case_contact, :active, casa_case: kase, created_at: Time.current.beginning_of_month + 1.day)
      create(:case_contact, :active, casa_case: kase, created_at: 1.month.ago.beginning_of_month + 1.day)
      # another chapter, this month -- must not leak in
      create(:case_contact, :active, casa_case: create(:casa_case, casa_org: create(:casa_org)), created_at: Time.current.beginning_of_month + 1.day)

      report = described_class.new(casa_org: org)
      expect(report.contacts_this_month).to eq(1)
      expect(report.contacts_previous_month).to eq(1)
    end
  end

  describe "#monthly_active_users" do
    let(:org) { create(:casa_org) }

    it "counts distinct signed-in volunteers, scoped to the org" do
      in_org = create(:volunteer, casa_org: org)
      out_org = create(:volunteer, casa_org: create(:casa_org))
      create(:login_activity, user: in_org, success: true, created_at: Time.current)
      create(:login_activity, user: out_org, success: true, created_at: Time.current)

      expect(described_class.new(casa_org: org).monthly_active_users(3)[:series][0][:data].last).to eq(1)
      expect(described_class.new.monthly_active_users(3)[:series][0][:data].last).to eq(2)
    end
  end
end
