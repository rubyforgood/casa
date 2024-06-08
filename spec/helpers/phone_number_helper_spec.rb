require "rails_helper"

RSpec.describe PhoneNumberHelper do
  describe "phone number helper" do
    include PhoneNumberHelper

    context "validates phone number" do
      it "with empty string" do
        valid, error = valid_phone_number("")
        expect(valid).to be(true)
        expect(error).to be_nil
      end

      it "with 10 digit phone number prepended with US country code" do
        valid, error = valid_phone_number("+12223334444")
        expect(valid).to be(true)
        expect(error).to be_nil
      end

      it "with 10 digit phone number prepended with US country code without the plus sign" do
        valid, error = valid_phone_number("12223334444")
        expect(valid).to be(true)
        expect(error).to be_nil
      end

      it "with 10 phone number with spaces" do
        valid, error = valid_phone_number("222 333 4444")
        expect(valid).to be(true)
        expect(error).to be_nil
      end

      it "with 10 phone number with parentheses" do
        valid, error = valid_phone_number("(222)3334444")
        expect(valid).to be(true)
        expect(error).to be_nil
      end

      it "with 10 phone number with dashes" do
        valid, error = valid_phone_number("222-333-4444")
        expect(valid).to be(true)
        expect(error).to be_nil
      end

      it "with 10 phone number with dots" do
        valid, error = valid_phone_number("222.333.4444")
        expect(valid).to be(true)
        expect(error).to be_nil
      end
    end

    context "invalidates phone number" do
      it "with incorrect country code" do
        valid, error = valid_phone_number("+22223334444")
        expect(valid).to be(false)
        expect(error).to have_text("must be 10 digits or 12 digits including country code (+1)")
      end

      it "with short phone number" do
        valid, error = valid_phone_number("+122")
        expect(valid).to be(false)
        expect(error).to have_text("must be 10 digits or 12 digits including country code (+1)")
      end

      it "with long phone number" do
        valid, error = valid_phone_number("+12223334444555")
        expect(valid).to be(false)
        expect(error).to have_text("must be 10 digits or 12 digits including country code (+1)")
      end
    end
  end
end
