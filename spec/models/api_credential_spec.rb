require 'rails_helper'
require 'digest'

RSpec.describe ApiCredential, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_one(:api_credential) }

  let(:user) { create(:user) }
  let(:api_credential) { create(:api_credential, user: user) }

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
      refresh_token = api_credential.return_new_refresh_token![:refresh_token]
      expect(api_credential.authenticate_refresh_token(refresh_token)).to be true
    end

    it "returns false for an invalid refresh_token" do
      expect(api_credential.authenticate_refresh_token("invalid_token")).to be false
    end
  end

  describe "#return_new_api_token!" do
    it "generates a new api_token and updates digest hash" do
      old_digest = api_credential.api_token_digest
      new_token = api_credential.return_new_api_token![:api_token]

      expect(api_credential.api_token_digest).not_to eq(old_digest)
      expect(api_credential.authenticate_api_token(new_token)).to be true
    end
  end

  describe "#return_new_refresh_token!" do
    it "generates a new refresh_token and updates digest hash" do
      old_digest = api_credential.refresh_token_digest
      new_token = api_credential.return_new_refresh_token![:refresh_token]

      expect(api_credential.refresh_token_digest).not_to eq(old_digest)
      expect(api_credential.authenticate_refresh_token(new_token)).to be true
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
  
  describe "#generate_api_token" do
    it "creates a secure hashed api_token when generated" do
      old_digest = api_credential.api_token_digest
      api_token = api_credential.return_new_api_token![:api_token]

      expect(api_credential.api_token_digest).not_to be_nil
      expect(api_credential.api_token_digest).to eq(Digest::SHA256.hexdigest(api_token))
      expect(api_credential.api_token_digest).not_to eq(old_digest)
    end
  end

  describe "#generate_refresh_token" do
    it "creates a secure hashed refresh_token when generated" do
        old_digest = api_credential.refresh_token_digest
        refresh_token = api_credential.return_new_refresh_token![:refresh_token]

        expect(api_credential.refresh_token_digest).not_to be_nil
        expect(api_credential.refresh_token_digest).to eq(Digest::SHA256.hexdigest(refresh_token))
        expect(api_credential.refresh_token_digest).not_to eq(old_digest)
    end
  end