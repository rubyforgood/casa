require "rails_helper"

RSpec.describe UserValidator, type: :validator do
  # NOTE: several messages asserted below (display name, communication
  # preferences, date of birth) have a leading space baked into the
  # validator's error strings. That's not a typo in this spec - it's
  # existing UserValidator behavior, already characterized in
  # spec/models/user_spec.rb.
  describe "phone number" do
    it "adds an error when the phone number is not 10 or 12 digits" do
      user = build(:user, phone_number: "12345")

      described_class.new.validate(user)

      expect(user.errors[:phone_number]).to include("must be 10 digits or 12 digits including country code (+1)")
    end

    it "does not add a phone number error for a valid 10 digit number" do
      user = build(:user, phone_number: "4165551234")

      described_class.new.validate(user)

      expect(user.errors[:phone_number]).to be_empty
    end

    it "does not add a phone number error when blank" do
      user = build(:user, phone_number: "")

      described_class.new.validate(user)

      expect(user.errors[:phone_number]).to be_empty
    end
  end

  describe "display name" do
    it "adds an error when display_name is blank" do
      user = build(:user, display_name: "")

      described_class.new.validate(user)

      expect(user.errors[:display_name]).to include(" can't be blank")
    end

    it "does not add an error when display_name is present" do
      user = build(:user, display_name: "Jane Doe")

      described_class.new.validate(user)

      expect(user.errors[:display_name]).to be_empty
    end
  end

  describe "communication preferences" do
    it "adds a base error when neither email nor sms notifications are selected" do
      user = build(:user, receive_email_notifications: false, receive_sms_notifications: false)

      described_class.new.validate(user)

      expect(user.errors[:base]).to include(" At least one communication preference must be selected.")
    end

    it "does not add an error when email notifications are selected" do
      user = build(:user, receive_email_notifications: true, receive_sms_notifications: false)

      described_class.new.validate(user)

      expect(user.errors[:base]).to be_empty
    end

    it "does not add an error when sms notifications are selected and a phone number is present" do
      user = build(:user, receive_email_notifications: false, receive_sms_notifications: true, phone_number: "4165551234")

      described_class.new.validate(user)

      expect(user.errors[:base]).to be_empty
    end
  end

  describe "phone number required for sms notifications" do
    it "adds a base error when sms notifications are on but phone number is blank" do
      user = build(:user, receive_sms_notifications: true, phone_number: "")

      described_class.new.validate(user)

      expect(user.errors[:base]).to include(" Must add a valid phone number to receive SMS notifications.")
    end

    it "does not add that error when sms notifications are off" do
      user = build(:user, receive_sms_notifications: false, phone_number: "")

      described_class.new.validate(user)

      expect(user.errors[:base]).not_to include(" Must add a valid phone number to receive SMS notifications.")
    end
  end

  describe "date of birth" do
    it "adds a base error when date_of_birth is in the future" do
      user = build(:user, date_of_birth: 10.days.from_now)

      described_class.new.validate(user)

      expect(user.errors[:base]).to include(" Date of birth must be in the past.")
    end

    it "adds a base error when date_of_birth is before 1920-01-01" do
      user = build(:user, date_of_birth: "1919-12-31".to_date)

      described_class.new.validate(user)

      expect(user.errors[:base]).to include(" Date of birth must be on or after 1/1/1920.")
    end

    it "does not add an error for a valid past date of birth" do
      user = build(:user, date_of_birth: 30.years.ago)

      described_class.new.validate(user)

      expect(user.errors[:base]).to be_empty
    end

    it "does not validate date_of_birth when it is blank" do
      user = build(:user, date_of_birth: nil)

      described_class.new.validate(user)

      expect(user.errors[:base]).to be_empty
    end
  end

  describe "email uniqueness" do
    it "adds a base error when another user already has the same email" do
      create(:user, email: "duplicate@example.com")
      user = build(:user, email: "duplicate@example.com")

      described_class.new.validate(user)

      expect(user.errors[:base]).to include(I18n.t("activerecord.errors.messages.email_uniqueness"))
    end

    it "does not add an error when the email is unique" do
      user = build(:user, email: "unique@example.com")

      described_class.new.validate(user)

      expect(user.errors[:base]).to be_empty
    end

    it "does not add an error when validating the existing record against itself" do
      user = create(:user, email: "self@example.com")

      described_class.new.validate(user)

      expect(user.errors[:base]).to be_empty
    end
  end
end
