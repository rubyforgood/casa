require "rails_helper"

RSpec.describe SmsBodyHelper, type: :helper do
  describe "#account_activation_msg" do
    it "correct short links provided" do
      expected_response = account_activation_msg("primogems", {0 => "www.pasta.com", 1 => "www.yogurt.com"})
      expect(expected_response).to include("First, set your password here www.pasta.com. Then visit www.yogurt.com to change your text message settings.")
    end

    it "incorrect short links provided" do
      expected_response = account_activation_msg("primogems", {0 => nil, 1 => nil})
      expect(expected_response).to include("Please check your email to set up your password. Go to profile edit page to change SMS settings.")
    end

    it "set up password link invalid" do
      expected_response = account_activation_msg("primogems", {0 => nil, 1 => "www.carfax.com"})
      expect(expected_response).to include("Please check your email to set up your password. Then visit www.carfax.com to change your text message settings.")
    end

    it "link to users/edit invalid" do
      expected_response = account_activation_msg("primogems", {0 => "www.yummy.com", 1 => nil})
      expect(expected_response).to include("First, set your password here www.yummy.com. Go to profile edit page to change SMS settings.")
    end
  end
end
