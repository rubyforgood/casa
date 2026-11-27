require "rails_helper"
require "support/stubbed_requests/webmock_helper"

RSpec.describe CasaOrg, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:time_zone) }
  it { is_expected.to have_many(:users).dependent(:destroy) }
  it { is_expected.to have_many(:casa_cases).dependent(:destroy) }
  it { is_expected.to have_many(:contact_type_groups).dependent(:destroy) }
  it { is_expected.to have_many(:hearing_types).dependent(:destroy) }
  it { is_expected.to have_many(:mileage_rates).dependent(:destroy) }
  it { is_expected.to have_many(:case_assignments).through(:users) }
  it { is_expected.to have_one_attached(:logo) }
  it { is_expected.to have_one_attached(:court_report_template) }
  it { is_expected.to have_many(:contact_topics) }
  it { is_expected.to have_many(:custom_org_links).dependent(:destroy) }

  it "has unique name" do
    org = create(:casa_org)
    new_org = build(:casa_org, name: org.name)
    expect(new_org.valid?).to be false
  end

  describe "time_zone validation" do
    subject(:casa_org) { build(:casa_org) }

    it "defaults to America/New_York" do
      expect(described_class.new.time_zone).to eq("America/New_York")
    end

    it "is valid with a valid IANA identifier like America/New_York" do
      casa_org.time_zone = "America/New_York"
      expect(casa_org).to be_valid
    end

    it "is valid with another valid IANA identifier like Asia/Kolkata" do
      casa_org.time_zone = "Asia/Kolkata"
      expect(casa_org).to be_valid
    end

    it "is invalid with an invalid identifier" do
      casa_org.time_zone = "Invalid/Timezone"
      expect(casa_org).not_to be_valid
      expect(casa_org.errors[:time_zone]).to include("is not a valid IANA time zone identifier")
    end

    it "is invalid with a Rails-friendly display name that is not a canonical IANA identifier" do
      casa_org.time_zone = "Eastern Time (US & Canada)"
      expect(casa_org).not_to be_valid
      expect(casa_org.errors[:time_zone]).to include("is not a valid IANA time zone identifier")
    end

    it "is invalid with a blank value" do
      casa_org.time_zone = ""
      expect(casa_org).not_to be_valid
      expect(casa_org.errors[:time_zone]).to include("can't be blank")
    end

    it "is invalid with nil" do
      casa_org.time_zone = nil
      expect(casa_org).not_to be_valid
      expect(casa_org.errors[:time_zone]).to include("can't be blank")
    end
  end

  describe "CasaOrgValidator" do
    let(:casa_org) { build(:casa_org) }

    it "delegates phone validation to PhoneNumberHelper" do
      expect_any_instance_of(PhoneNumberHelper).to receive(:valid_phone_number).once.with(casa_org.twilio_phone_number)
      casa_org.valid?
    end
  end

  describe "validate validate_twilio_credentials" do
    let(:casa_org) { create(:casa_org, twilio_enabled: true) }
    let(:twilio_rest_error) do
      error_response = double("error_response", status_code: 401, body: {})
      Twilio::REST::RestError.new("Error message", error_response)
    end

    it "validates twillio credentials on update", :aggregate_failures do
      twillio_client = instance_double(Twilio::REST::Client)
      allow(Twilio::REST::Client).to receive(:new).and_return(twillio_client)
      allow(twillio_client).to receive_message_chain(:messages, :list).and_raise(twilio_rest_error)

      %i[twilio_account_sid twilio_api_key_sid twilio_api_key_secret].each do |field|
        update_successful = casa_org.update(field => "")
        aggregate_failures do
          expect(update_successful).to be false
          expect(casa_org.errors[:base]).to eq ["Your Twilio credentials are incorrect, kindly check and try again."]
        end
      end
    end

    it "returns error if credentials form invalid URI" do
      twillio_client = instance_double(Twilio::REST::Client)
      allow(Twilio::REST::Client).to receive(:new).and_return(twillio_client)
      allow(twillio_client).to receive_message_chain(:messages, :list).and_raise(URI::InvalidURIError)

      casa_org.update(twilio_account_sid: "some bad value")

      aggregate_failures do
        expect(casa_org).not_to be_valid
        expect(casa_org.errors[:base]).to eq ["Your Twilio credentials are incorrect, kindly check and try again."]
      end
    end

    context "org with disabled twilio" do
      let(:casa_org) { create(:casa_org, twilio_enabled: false) }

      it "validates twillio credentials on update", :aggregate_failures do
        %i[twilio_account_sid twilio_api_key_sid twilio_api_key_secret].each do |field|
          expect(casa_org.update(field => "")).to be true
        end
      end
    end
  end

  describe "Attachment" do
    it "is valid" do
      aggregate_failures do
        subject = build(:casa_org, twilio_enabled: false)

        expect(subject.org_logo).to eq(Pathname.new("#{Rails.public_path.join("logo.jpeg")}"))

        subject.logo.attach(
          io: File.open(file_fixture("company_logo.png")),
          filename: "company_logo.png", content_type: "image/png"
        )

        subject.save!

        expect(subject.logo).to be_an_instance_of(ActiveStorage::Attached::One)
        expect(subject.org_logo).to eq("/rails/active_storage/blobs/redirect/#{subject.logo.signed_id}/#{subject.logo.filename}")
      end
    end
  end

  context "when creating an organization" do
    let(:org) { create(:casa_org, name: "Prince George CASA") }

    it "has a slug based on the name" do
      expect(org.slug).to eq "prince-george-casa"
    end
  end

  describe "generate_defaults" do
    let(:org) { create(:casa_org) }
    let(:fake_topics) { [{"question" => "Test Title", "details" => "Test details"}] }

    before do
      allow(ContactTopic).to receive(:default_contact_topics).and_return(fake_topics)
      org.generate_defaults
    end

    describe "generates default contact type groups" do
      let(:groups) { ContactTypeGroup.where(casa_org: org).joins(:contact_types).pluck(:name, "contact_types.name").sort }

      it "matches default contact type groups" do
        expect(groups).to eq([["CASA", "Supervisor"],
          ["CASA", "Youth"],
          ["Education", "Guidance counselor"],
          ["Education", "IEP team"],
          ["Education", "School"],
          ["Education", "Teacher"],
          ["Family", "Aunt, uncle, or cousin"],
          ["Family", "Fictive kin"],
          ["Family", "Grandparent"],
          ["Family", "Other family"],
          ["Family", "Parent"],
          ["Family", "Sibling"],
          ["Health", "Medical professional"],
          ["Health", "Mental health therapist"],
          ["Health", "Other therapist"],
          ["Health", "Psychiatric practitioner"],
          ["Legal", "Attorney"],
          ["Legal", "Court"],
          ["Placement", "Caregiver family"],
          ["Placement", "Foster parent"],
          ["Placement", "Therapeutic agency worker"],
          ["Social services", "Social worker"]])
      end
    end

    describe "generates default hearing types" do
      let(:hearing_types_names) { HearingType.where(casa_org: org).pluck(:name) }

      it "matches default hearing types" do
        expect(hearing_types_names).to include(*HearingType::DEFAULT_HEARING_TYPES)
      end
    end

    describe "generates default contact topics" do
      let(:contact_topics) { ContactTopic.where(casa_org: org).map(&:question) }

      it "matches default contact topics" do
        expected = fake_topics.pluck("question")
        expect(contact_topics).to include(*expected)
      end
    end
  end

  describe "mileage rate for a given date" do
    let(:casa_org) { build(:casa_org) }

    describe "with a casa org with no rates" do
      it "is nil" do
        expect(casa_org.mileage_rate_for_given_date(Date.today)).to be_nil
      end
    end

    describe "with a casa org with inactive dates" do
      let!(:mileage_rates) do
        [
          create(:mileage_rate, casa_org: casa_org, effective_date: 10.days.ago, is_active: false),
          create(:mileage_rate, casa_org: casa_org, effective_date: 3.days.ago, is_active: false)
        ]
      end

      it "is nil" do
        expect(casa_org.mileage_rates.count).to eq 2
        expect(casa_org.mileage_rate_for_given_date(Date.today)).to be_nil
      end
    end

    describe "with active dates in the future" do
      let!(:mileage_rate) { create(:mileage_rate, casa_org: casa_org, effective_date: 3.days.from_now) }

      it "is nil" do
        expect(casa_org.mileage_rates.count).to eq 1
        expect(casa_org.mileage_rate_for_given_date(Date.today)).to be_nil
      end
    end

    describe "with active dates in the past" do
      let!(:mileage_rates) do
        [
          create(:mileage_rate, casa_org: casa_org, amount: 4.50, effective_date: 20.days.ago),
          create(:mileage_rate, casa_org: casa_org, amount: 5.50, effective_date: 10.days.ago),
          create(:mileage_rate, casa_org: casa_org, amount: 6.50, effective_date: 3.days.ago)
        ]
      end

      it "uses the most recent date" do
        expect(casa_org.mileage_rate_for_given_date(12.days.ago.to_date)).to eq 4.50
        expect(casa_org.mileage_rate_for_given_date(5.days.ago.to_date)).to eq 5.50
        expect(casa_org.mileage_rate_for_given_date(Date.today)).to eq 6.50
      end
    end
  end

  describe "organization time helpers" do
    let(:casa_org) { build(:casa_org, time_zone: "America/New_York") }

    describe "#time_zone_object" do
      it "returns the ActiveSupport::TimeZone for a valid configured time zone" do
        casa_org.time_zone = "America/Los_Angeles"
        expect(casa_org.time_zone_object).to eq(ActiveSupport::TimeZone["America/Los_Angeles"])
      end

      it "falls back to America/New_York when time_zone is nil" do
        casa_org.time_zone = nil
        expect(casa_org.time_zone_object).to eq(ActiveSupport::TimeZone["America/New_York"])
      end

      it "falls back to America/New_York when time_zone is an invalid identifier" do
        casa_org.time_zone = "Invalid/Time_Zone"
        expect(casa_org.time_zone_object).to eq(ActiveSupport::TimeZone["America/New_York"])
      end

      it "resolves all TZInfo identifiers without raising" do
        TZInfo::Timezone.all_identifiers.each do |identifier|
          zone = Time.find_zone(identifier)
          expect(zone).to be_a(ActiveSupport::TimeZone), "Expected #{identifier} to resolve to ActiveSupport::TimeZone"
        end
      end
    end

    describe "#with_time_zone" do
      it "sets Time.zone to the organization's time zone within the block" do
        casa_org.time_zone = "America/Los_Angeles"
        Time.use_zone("UTC") do
          casa_org.with_time_zone do
            expect(Time.zone.name).to eq("America/Los_Angeles")
          end
          expect(Time.zone.name).to eq("UTC")
        end
      end

      it "returns the block result" do
        result = casa_org.with_time_zone { "test result" }
        expect(result).to eq("test result")
      end

      it "restores the previous Time.zone even if an exception occurs" do
        Time.use_zone("UTC") do
          expect {
            casa_org.with_time_zone { raise "deliberate error" }
          }.to raise_error("deliberate error")
          expect(Time.zone.name).to eq("UTC")
        end
      end
    end

    describe "date and time helpers across multiple time zones around UTC midnight" do
      # 2026-11-23 02:00:00 UTC:
      # Honolulu (-10h): 2026-11-22 16:00:00 HST
      # Los Angeles (-8h): 2026-11-22 18:00:00 PST
      # New York (-5h): 2026-11-22 21:00:00 EST
      # London (+0h): 2026-11-23 02:00:00 GMT
      # Kolkata (+5:30h): 2026-11-23 07:30:00 IST
      before do
        travel_to Time.utc(2026, 11, 23, 2, 0, 0)
      end

      it "evaluates correctly for Pacific/Honolulu" do
        casa_org.time_zone = "Pacific/Honolulu"
        expect(casa_org.time_zone_now.hour).to eq(16)
        expect(casa_org.today).to eq(Date.new(2026, 11, 22))
        expect(casa_org.yesterday).to eq(Date.new(2026, 11, 21))
        expect(casa_org.tomorrow).to eq(Date.new(2026, 11, 23))
      end

      it "evaluates correctly for America/Los_Angeles" do
        casa_org.time_zone = "America/Los_Angeles"
        expect(casa_org.time_zone_now.hour).to eq(18)
        expect(casa_org.today).to eq(Date.new(2026, 11, 22))
        expect(casa_org.yesterday).to eq(Date.new(2026, 11, 21))
        expect(casa_org.tomorrow).to eq(Date.new(2026, 11, 23))
      end

      it "evaluates correctly for America/New_York" do
        casa_org.time_zone = "America/New_York"
        expect(casa_org.time_zone_now.hour).to eq(21)
        expect(casa_org.today).to eq(Date.new(2026, 11, 22))
        expect(casa_org.yesterday).to eq(Date.new(2026, 11, 21))
        expect(casa_org.tomorrow).to eq(Date.new(2026, 11, 23))
      end

      it "evaluates correctly for Europe/London" do
        casa_org.time_zone = "Europe/London"
        expect(casa_org.time_zone_now.hour).to eq(2)
        expect(casa_org.today).to eq(Date.new(2026, 11, 23))
        expect(casa_org.yesterday).to eq(Date.new(2026, 11, 22))
        expect(casa_org.tomorrow).to eq(Date.new(2026, 11, 24))
      end

      it "evaluates correctly for Asia/Kolkata" do
        casa_org.time_zone = "Asia/Kolkata"
        expect(casa_org.time_zone_now.hour).to eq(7)
        expect(casa_org.time_zone_now.min).to eq(30)
        expect(casa_org.today).to eq(Date.new(2026, 11, 23))
        expect(casa_org.yesterday).to eq(Date.new(2026, 11, 22))
        expect(casa_org.tomorrow).to eq(Date.new(2026, 11, 24))
      end
    end

    describe "DST transition behavior" do
      context "during spring forward (EST -> EDT)" do
        it "correctly resolves time and date across the transition" do
          casa_org.time_zone = "America/New_York"
          travel_to Time.utc(2026, 3, 8, 7, 30, 0) # 02:30 EST jumps to 03:30 EDT
          expect(casa_org.today).to eq(Date.new(2026, 3, 8))
          expect(casa_org.time_zone_now.zone).to eq("EDT")
        end
      end

      context "during fall back (EDT -> EST)" do
        it "correctly resolves time and date across the transition" do
          casa_org.time_zone = "America/New_York"
          travel_to Time.utc(2026, 11, 1, 6, 30, 0) # 01:30 repeats; 06:30 UTC is 01:30 EST
          expect(casa_org.today).to eq(Date.new(2026, 11, 1))
          expect(casa_org.time_zone_now.zone).to eq("EST")
        end
      end
    end
  end
end
