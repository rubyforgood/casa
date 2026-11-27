require "rails_helper"

RSpec.describe CasaOrgHelper, type: :helper do
  describe "#grouped_time_zone_options" do
    let(:groups) { helper.grouped_time_zone_options }
    let(:us_group) { groups.find { |name, _| name == "United States" } }
    let(:other_group) { groups.find { |name, _| name == "Other" } }

    it "returns two groups: United States and Other" do
      expect(groups.map(&:first)).to eq(["United States", "Other"])
    end

    it "includes major US time zones in the United States group" do
      us_options = us_group.second
      us_identifiers = us_options.map(&:last)

      expect(us_identifiers).to include(
        "America/New_York",
        "America/Chicago",
        "America/Denver",
        "America/Los_Angeles",
        "America/Anchorage",
        "Pacific/Honolulu",
        "America/Phoenix"
      )
    end

    it "includes non-US IANA time zones in the Other group" do
      other_options = other_group.second
      other_identifiers = other_options.map(&:last)

      expect(other_identifiers).to include(
        "Asia/Kolkata",
        "Europe/London",
        "Europe/Paris",
        "Australia/Sydney"
      )
      expect(other_identifiers).not_to include("America/New_York")
    end

    it "contains valid IANA identifiers across all options" do
      all_identifiers = (us_group.second + other_group.second).map(&:last)

      all_identifiers.each do |identifier|
        expect(TZInfo::Timezone.all_identifiers).to include(identifier)
      end
    end

    it "contains no duplicate identifiers between groups" do
      us_identifiers = us_group.second.map(&:last)
      other_identifiers = other_group.second.map(&:last)

      overlap = us_identifiers & other_identifiers
      expect(overlap).to be_empty
    end
  end
end
