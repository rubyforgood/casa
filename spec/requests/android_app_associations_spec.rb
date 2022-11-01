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
      allow(ENV).to receive(:[]).with("ANDROID_CERTIFICATE_FINGERPRINT").and_return("fingeprint")
    end

    it "renders a json file" do
      get "/.well-known/assetlinks.json"

      expect(response.header["Content-Type"]).to include("application/json")
      expect(response.body).to match(reponse_json)
    end
  end
end
