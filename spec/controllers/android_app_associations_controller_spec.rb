require "rails_helper"

RSpec.describe AndroidAppAssociationsController, type: :controller do
  describe "#index" do
    subject { get :index }

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
      ENV["ANDROID_CERTIFICATE_FINGERPRINT"] = "fingerprint"
    end
    it do
      subject
      expect(response.body).to match(reponse_json)
    end
  end
end
