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

  describe "#volunteer_reactivation_msg" do
    it "greets the volunteer and explains they can reuse their old credentials" do
      expect(volunteer_reactivation_msg("Ali Ahmed")).to eq(
        "Hello Ali Ahmed, \n \n Your CASA/Prince George’s County volunteer console account has been reactivated. You can login using the credentials you were already using. \n \n If you have any questions, please contact your most recent Case Supervisor for assistance. \n \n CASA/Prince George’s County"
      )
    end

    it "handles a blank display name without raising" do
      expect { volunteer_reactivation_msg(nil) }.not_to raise_error
      expect(volunteer_reactivation_msg(nil)).to start_with("Hello ,")
    end
  end
end
