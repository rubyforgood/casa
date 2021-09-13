class AndroidAppAssociationsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    android_asset_link_data = [
      {
        relation: ["delegate_permission/common.handle_all_urls"],
        target: {
          namespace: "android_app",
          package_name: "org.rubyforgood.casa",
          sha256_cert_fingerprints: [ENV["ANDROID_CERTIFICATE_FINGERPRINT"]]
        }
      }
    ]

    render json: android_asset_link_data.to_json
  end
end
