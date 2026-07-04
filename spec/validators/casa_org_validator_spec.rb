require "rails_helper"

RSpec.describe CasaOrgValidator, type: :validator do
  describe "twilio phone number" do
    # NOTE: the validator adds this error to :number, which is not a real
    # CasaOrg attribute (the column is :twilio_phone_number) - see
    # app/validators/casa_org_validator.rb. This looks like a bug, but these
    # specs characterize the validator's actual current behavior rather than
    # the presumably intended one.
    it "adds an error on :number when the twilio phone number is not 10 or 12 digits" do
      casa_org = build(:casa_org, twilio_phone_number: "12345")

      described_class.new.validate(casa_org)

      expect(casa_org.errors.added?(:number, "must be 10 digits or 12 digits including country code (+1)")).to be true
    end

    it "adds an error on :number when the twilio phone number contains non-digit characters" do
      casa_org = build(:casa_org, twilio_phone_number: "+1416eee4325")

      described_class.new.validate(casa_org)

      expect(casa_org.errors.added?(:number, "must be 10 digits or 12 digits including country code (+1)")).to be true
    end

    it "does not add an error for a valid 12 digit twilio phone number" do
      casa_org = build(:casa_org, twilio_phone_number: "+15555555555")

      described_class.new.validate(casa_org)

      expect(casa_org.errors[:number]).to be_empty
    end

    it "does not add an error when the twilio phone number is blank" do
      casa_org = build(:casa_org, twilio_phone_number: "")

      described_class.new.validate(casa_org)

      expect(casa_org.errors[:number]).to be_empty
    end
  end
end
