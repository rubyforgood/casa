require "rails_helper"

RSpec.describe PhoneNumberHelper do
  describe "phone number helper" do
    include PhoneNumberHelper

    context "valid phone number" do
      it 'with empty string' do
        valid, error = valid_phone_number("")
        expect(valid).to be(true)
        expect(error).to be_nil
      end

      it "with correct country code and 12 digits" do
        valid, error = valid_phone_number("+12223334444")
        expect(valid).to be(true)
        expect(error).to be_nil
      end

      it "with 10 digits" do
        valid, error = valid_phone_number("2223334444")
        expect(valid).to be(true)
        expect(error).to be_nil
      end
    end

    context "invalid phone number" do
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
