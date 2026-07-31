require "rails_helper"

RSpec.describe "AndroidAppAssociations", type: :request do
  describe "GET /.well-known/assetlinks.json" do
    let(:reponse_json) do
      [
        {
          relation: [
            "delegate_permission/common.handle_all_urls"
          ],
          target: {
            namespace: "android_app",
            package_name: "org.rubyforgood.casa",
            sha256_cert_fingerprints: ["fingerprint"]
          }
        }
      ].to_json
    end

    before do
      # `and_call_original` FIRST, then the specific arg. A partial double constrained only by `.with`
      # raises on any other argument, and ENV[] is read by half the stack -- Flipper's middleware asks
      # for FLIPPER_CLOUD_TOKEN on the way through, which blew up this request and, because the double
      # lives on the real ENV constant, every example that ran after it in the same process. Seen for
      # real: seed 16083 turned 1 failure into 1697.
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("ANDROID_CERTIFICATE_FINGERPRINT").and_return("fingeprint")
    end

    it "renders a json file" do
      get "/.well-known/assetlinks.json"

      expect(response.header["Content-Type"]).to include("application/json")
      expect(response.body).to match(reponse_json)
    end
  end
end
