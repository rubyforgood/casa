require "rails_helper"
require "support/stubbed_requests/webmock_helper"

RSpec.describe CasaOrg, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to have_many(:users).dependent(:destroy) }
  it { is_expected.to have_many(:casa_cases).dependent(:destroy) }
  it { is_expected.to have_many(:contact_type_groups).dependent(:destroy) }
  it { is_expected.to have_many(:hearing_types).dependent(:destroy) }
  it { is_expected.to have_many(:mileage_rates).dependent(:destroy) }
  it { is_expected.to have_many(:case_assignments).through(:users) }
  it { is_expected.to have_one_attached(:logo) }
  it { is_expected.to have_one_attached(:court_report_template) }
  it { is_expected.to have_many(:contact_topics) }
  it { is_expected.to have_many(:standard_court_orders).dependent(:destroy) }

  it "has unique name" do
    org = create(:casa_org)
    new_org = build(:casa_org, name: org.name)
    expect(new_org.valid?).to be false
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
        expect(casa_org).to_not be_valid
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

        expect(subject.org_logo).to eq(Pathname.new("#{Rails.root}/public/logo.jpeg"))

        subject.logo.attach(
          io: File.open("#{Rails.root}/spec/fixtures/company_logo.png"),
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
          ["Education", "Guidance Counselor"],
          ["Education", "IEP Team"],
          ["Education", "School"],
          ["Education", "Teacher"],
          ["Family", "Aunt Uncle or Cousin"],
          ["Family", "Fictive Kin"],
          ["Family", "Grandparent"],
          ["Family", "Other Family"],
          ["Family", "Parent"],
          ["Family", "Sibling"],
          ["Health", "Medical Professional"],
          ["Health", "Mental Health Therapist"],
          ["Health", "Other Therapist"],
          ["Health", "Psychiatric Practitioner"],
          ["Legal", "Attorney"],
          ["Legal", "Court"],
          ["Placement", "Caregiver Family"],
          ["Placement", "Foster Parent"],
          ["Placement", "Therapeutic Agency Worker"],
          ["Social Services", "Social Worker"]])
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
        expected = fake_topics.map { |topic| topic["question"] }
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
end
