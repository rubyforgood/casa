require "rails_helper"

RSpec.describe UserDecorator do
  describe "#status" do
    context "when user role is inactive" do
      it "returns Inactive" do
        volunteer = build(:volunteer, :inactive)

        expect(volunteer.decorate.status).to eq "Inactive"
      end
    end

    context "when user role is volunteer" do
      it "returns Active" do
        volunteer = build(:volunteer)

        expect(volunteer.decorate.status).to eq "Active"
      end
    end
  end

  let(:user) { create(:user) }
  let(:decorated_user) { user.decorate }

  describe "#formatted_created_at" do
    context "when using the 'default'format string"
    it "returns the correctly formatted date" do
      user.update(created_at: Time.new(2023, 5, 1, 12, 0, 0))
      expected_date = I18n.l(user.created_at, format: :full, default: nil)
      expect(decorated_user.formatted_created_at).to eq expected_date
    end

    context "when passing in the custom :edit_profile format string"
    it "returns the correctly formatted date" do
      user.update(created_at: Time.new(2023, 5, 1, 12, 0, 0))
      expected_date = I18n.l(user.created_at, format: :edit_profile, default: nil)
      decorated_user.context[:format] = :edit_profile
      expect(decorated_user.formatted_created_at).to eq expected_date
    end
  end

  describe "#formatted_updated_at" do
    context "when using the 'default'format string"
    it "returns the correctly formatted date" do
      user.update(updated_at: Time.new(2023, 5, 1, 12, 0, 0))
      expected_date = I18n.l(user.updated_at, format: :full, default: nil)
      expect(decorated_user.formatted_updated_at).to eq expected_date
    end

    context "when passing in the custom :edit_profile format string"
    it "returns the correctly formatted date" do
      user.update(updated_at: Time.new(2023, 5, 1, 12, 0, 0))
      expected_date = I18n.l(user.updated_at, format: :edit_profile, default: nil)
      decorated_user.context[:format] = :edit_profile
      expect(decorated_user.formatted_updated_at).to eq expected_date
    end
  end

  describe "#formatted_current_sign_in_at" do
    context "when using the 'default'format string"
    it "returns the correctly formatted date" do
      user.update(current_sign_in_at: Time.new(2023, 5, 1, 12, 0, 0))
      expected_date = I18n.l(user.current_sign_in_at, format: :full, default: nil)
      expect(decorated_user.formatted_current_sign_in_at).to eq expected_date
    end

    context "when passing in the custom :edit_profile format string"
    it "returns the correctly formatted date" do
      user.update(current_sign_in_at: Time.new(2023, 5, 1, 12, 0, 0))
      expected_date = I18n.l(user.current_sign_in_at, format: :edit_profile, default: nil)
      decorated_user.context[:format] = :edit_profile
      expect(decorated_user.formatted_current_sign_in_at).to eq expected_date
    end
  end

  describe "#formatted_invitation_accepted_at" do
    context "when using the 'default'format string"
    it "returns the correctly formatted date" do
      user.update(invitation_accepted_at: Time.new(2023, 5, 1, 12, 0, 0))
      expected_date = I18n.l(user.invitation_accepted_at, format: :full, default: nil)
      expect(decorated_user.formatted_invitation_accepted_at).to eq expected_date
    end

    context "when passing in the custom :edit_profile format string"
    it "returns the correctly formatted date" do
      user.update(invitation_accepted_at: Time.new(2023, 5, 1, 12, 0, 0))
      expected_date = I18n.l(user.invitation_accepted_at, format: :edit_profile, default: nil)
      decorated_user.context[:format] = :edit_profile
      expect(decorated_user.formatted_invitation_accepted_at).to eq expected_date
    end
  end

  describe "#formatted_reset_password_sent_at" do
    context "when using the 'default'format string"
    it "returns the correctly formatted date" do
      user.update(reset_password_sent_at: Time.new(2023, 5, 1, 12, 0, 0))
      expected_date = I18n.l(user.reset_password_sent_at, format: :full, default: nil)
      expect(decorated_user.formatted_reset_password_sent_at).to eq expected_date
    end

    context "when passing in the custom :edit_profile format string"
    it "returns the correctly formatted date" do
      user.update(reset_password_sent_at: Time.new(2023, 5, 1, 12, 0, 0))
      expected_date = I18n.l(user.reset_password_sent_at, format: :edit_profile, default: nil)
      decorated_user.context[:format] = :edit_profile
      expect(decorated_user.formatted_reset_password_sent_at).to eq expected_date
    end
  end

  describe "#formatted_invitation_sent_at" do
    context "when using the 'default'format string"
    it "returns the correctly formatted date" do
      user.update(invitation_sent_at: Time.new(2023, 5, 1, 12, 0, 0))
      expected_date = I18n.l(user.invitation_sent_at, format: :full, default: nil)
      expect(decorated_user.formatted_invitation_sent_at).to eq expected_date
    end

    context "when passing in the custom :edit_profile format string"
    it "returns the correctly formatted date" do
      user.update(invitation_sent_at: Time.new(2023, 5, 1, 12, 0, 0))
      expected_date = I18n.l(user.invitation_sent_at, format: :edit_profile, default: nil)
      decorated_user.context[:format] = :edit_profile
      expect(decorated_user.formatted_invitation_sent_at).to eq expected_date
    end
  end

  describe "#formatted_birthday" do
    context "when a user has no date of birth set"
    it "returns a blank string" do
      user.update(date_of_birth: nil)
      expect(decorated_user.formatted_birthday).to eq ""
    end

    context "when a user has a valid date of birth"
    it "returns the month and ordinal of their birthday" do
      user.update(date_of_birth: Date.new(1991, 7, 8))
      expect(decorated_user.formatted_birthday).to eq "July 8th"
    end
  end

  describe "#formatted_date_of_birth" do
    context "when a user has no date of birth set"
    it "returns a blank string" do
      user.update(date_of_birth: nil)
      expect(decorated_user.formatted_date_of_birth).to eq ""
    end

    context "when a user has a valid date of birth"
    it "returns the YYYY/MM/DD of their date of birth" do
      user.update(date_of_birth: Date.new(1991, 7, 8))
      expect(decorated_user.formatted_date_of_birth).to eq "1991/07/08"
    end
  end
end
