require "rails_helper"
require "digest"

RSpec.describe ApiCredential, type: :model do
  let(:api_credential) { create(:api_credential, user: user) }
  let(:user) { create(:user) }

  it { is_expected.to belong_to(:user) }

  describe "#authenticate_api_token" do
    it "returns true for a valid api_token" do
      api_token = api_credential.return_new_api_token![:api_token]
      expect(api_credential.authenticate_api_token(api_token)).to be true
    end

    it "returns false for an invalid api_token" do
      expect(api_credential.authenticate_api_token("invalid_token")).to be false
    end
  end

  describe "#authenticate_refresh_token" do
    it "returns true for a valid refresh_token" do
      refresh_token = api_credential.return_new_refresh_token!(false)[:refresh_token]
      expect(api_credential.authenticate_refresh_token(refresh_token)).to be true
    end

    it "returns false for an invalid refresh_token" do
      expect(api_credential.authenticate_refresh_token("invalid_token")).to be false
    end
  end

  describe "#return_new_api_token!" do
    it "updates the api_token digest" do
      old_digest = api_credential.api_token_digest
      api_credential.return_new_api_token![:api_token]
      api_credential.reload
      expect(api_credential.api_token_digest).not_to eq(old_digest)
    end

    it "sets a new api_token" do
      new_token = api_credential.return_new_api_token![:api_token]

      expect(new_token).not_to be_nil
    end
  end

  describe "#return_new_refresh_token!" do
    it "updates the refresh_token digest" do
      old_digest = api_credential.refresh_token_digest
      api_credential.return_new_refresh_token!(false)[:refresh_token]
      api_credential.reload
      expect(api_credential.refresh_token_digest).not_to eq(old_digest)
    end

    it "sets a new refresh_token" do
      new_token = api_credential.return_new_refresh_token!(false)[:refresh_token]

      expect(new_token).not_to be_nil
    end
  end

  describe "#is_api_token_expired?" do
    it "returns false if token is still valid" do
      api_credential.update!(token_expires_at: 1.hour.from_now)
      expect(api_credential.is_api_token_expired?).to be false
    end

    it "returns true if token is expired" do
      api_credential.update!(token_expires_at: 1.hour.ago)
      expect(api_credential.is_api_token_expired?).to be true
    end
  end

  describe "#is_refresh_token_expired?" do
    it "returns false if token is still valid" do
      api_credential.update!(refresh_token_expires_at: 1.hour.from_now)
      expect(api_credential.is_refresh_token_expired?).to be false
    end

    it "returns true if token is expired" do
      api_credential.update!(token_expires_at: 1.hour.ago)
      expect(api_credential.is_api_token_expired?).to be true
    end
  end

  describe "#generate_api_token" do
    it "creates a secure hashed api_token" do
      api_credential.api_token_digest
      api_token = api_credential.return_new_api_token![:api_token]

      expect(api_credential.api_token_digest).to eq(Digest::SHA256.hexdigest(api_token))
    end
  end

  describe "#generate_refresh_token" do
    it "creates a secure hashed refresh_token" do
      api_credential.refresh_token_digest
      refresh_token = api_credential.return_new_refresh_token!(false)[:refresh_token]

      expect(api_credential.refresh_token_digest).to eq(Digest::SHA256.hexdigest(refresh_token))
    end
  end

  describe "#revoke_api_token" do
    it "sets api token to nil" do
      api_credential.return_new_api_token![:api_token]
      api_credential.revoke_api_token

      expect(api_credential.api_token_digest).to be_nil
    end
  end

  describe "#revoke_refresh_token" do
    it "sets refresh token to nil" do
      api_credential.return_new_refresh_token!(false)[:refresh_token]
      api_credential.revoke_refresh_token

      expect(api_credential.refresh_token_digest).to be_nil
    end
  end

  describe "#generate_refresh_token_with_rememberme" do
    it "updates token to be valid for 1 year" do
      api_credential.refresh_token_digest
      api_credential.return_new_refresh_token!(true)[:refresh_token]

      expect(api_credential.refresh_token_expires_at).to be_within(1.minutes).of(1.year.from_now)
    end
  end

  describe "#generate_refresh_token_without_rememberme" do
    it "updates token to be valid for 30 days" do
      api_credential.refresh_token_digest
      api_credential.return_new_refresh_token!(false)[:refresh_token]

      expect(api_credential.refresh_token_expires_at).to be_within(1.minutes).of(30.days.from_now)
    end
  end
end
