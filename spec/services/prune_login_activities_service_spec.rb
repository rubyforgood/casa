require "rails_helper"
require "bigdecimal"

RSpec.describe PruneLoginActivitiesService do
  describe "#perform" do
    it "deletes login activities strictly older than 13 months" do
      create(:login_activity, created_at: 14.months.ago)

      expect { described_class.new.perform }.to change(LoginActivity, :count).by(-1)
    end

    it "keeps login activities inside the retention window" do
      create(:login_activity, created_at: 12.months.ago)
      create(:login_activity, created_at: 1.month.ago)
      create(:login_activity, created_at: Time.current)

      expect { described_class.new.perform }.not_to change(LoginActivity, :count)
    end

    it "uses frozen time to verify cutoff boundary conditions" do
      freeze_time do
        cutoff = 13.months.ago
        older = create(:login_activity, created_at: cutoff - 1.second)
        exact = create(:login_activity, created_at: cutoff)
        newer = create(:login_activity, created_at: cutoff + 1.second)

        expect { described_class.new.perform }.to change(LoginActivity, :count).by(-1)
        expect(LoginActivity.exists?(older.id)).to be false
        expect(LoginActivity.exists?(exact.id)).to be true
        expect(LoginActivity.exists?(newer.id)).to be true
      end
    end

    it "never modifies or selectively wipes identity, ip, or other fields on surviving rows" do
      surviving = create(
        :login_activity,
        identity: "user@example.com",
        ip: "192.168.1.100",
        user_agent: "TestAgent/1.0",
        success: false,
        failure_reason: "invalid_credentials",
        created_at: 2.months.ago
      )
      create(:login_activity, created_at: 14.months.ago)

      described_class.new.perform

      reloaded = surviving.reload
      expect(reloaded.identity).to eq("user@example.com")
      expect(reloaded.ip).to eq("192.168.1.100")
      expect(reloaded.user_agent).to eq("TestAgent/1.0")
      expect(reloaded.success).to be false
      expect(reloaded.failure_reason).to eq("invalid_credentials")
    end

    it "returns the total number of deleted records" do
      create_list(:login_activity, 3, created_at: 14.months.ago)
      create_list(:login_activity, 2, created_at: 6.months.ago)

      expect(described_class.new.perform).to eq(3)
    end

    it "returns 0 when there are no matching records to prune" do
      create_list(:login_activity, 2, created_at: 3.months.ago)

      expect(described_class.new.perform).to eq(0)
    end

    it "honours a custom retention window greater than or equal to 13 months" do
      create(:login_activity, created_at: 14.months.ago)

      expect { described_class.new(months: 15).perform }.not_to change(LoginActivity, :count)
      expect { described_class.new(months: "15").perform }.not_to change(LoginActivity, :count)
      expect { described_class.new(months: 13).perform }.to change(LoginActivity, :count).by(-1)
    end

    it "refuses retention windows under 13 months" do
      expect { described_class.new(months: 12) }.to raise_error(ArgumentError, /at least 13 months/)
      expect { described_class.new(months: "12") }.to raise_error(ArgumentError, /at least 13 months/)
      expect { described_class.new(months: 0) }.to raise_error(ArgumentError, /at least 13 months/)
      expect { described_class.new(months: -1) }.to raise_error(ArgumentError, /at least 13 months/)
    end

    it "refuses fractional or non-numeric values without silently truncating" do
      expect { described_class.new(months: 13.5) }.to raise_error(ArgumentError, /whole number/)
      expect { described_class.new(months: BigDecimal("13.5")) }.to raise_error(ArgumentError, /whole number/)
      expect { described_class.new(months: Rational(27, 2)) }.to raise_error(ArgumentError, /whole number/)
      expect { described_class.new(months: "13.5") }.to raise_error(ArgumentError, /whole number/)
      expect { described_class.new(months: "13.0") }.to raise_error(ArgumentError, /whole number/)
      expect { described_class.new(months: "abc") }.to raise_error(ArgumentError, /whole number/)
      expect { described_class.new(months: "") }.to raise_error(ArgumentError, /whole number/)
      expect { described_class.new(months: nil) }.to raise_error(ArgumentError, /cannot be nil/)
    end
  end
end
