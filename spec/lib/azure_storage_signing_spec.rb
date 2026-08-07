require "rails_helper"
require "azure/storage/blob"

# Production stores every attachment on Azure (config.active_storage.service = :microsoft),
# and azure-storage-common signs both uploads and download URLs with CGI.parse. Ruby 4.0's
# stdlib cgi ships only escape/unescape, so the Gemfile has to pin the real cgi gem back in
# — Rails 8 stopped pulling it in transitively. When that pin goes missing, every Active
# Storage read and write 500s in production while CI stays green, because the test
# environment uses Disk storage and never touches this code.
#
# See https://github.com/rubyforgood/casa/issues/7093
RSpec.describe "Azure Storage request signing" do
  let(:account_name) { "casaaccount" }
  let(:access_key) { Base64.strict_encode64("not-a-real-key") }

  it "has the full CGI library, not Ruby 4.0's escape-only stdlib" do
    expect(CGI).to respond_to(:parse)
  end

  # Exercised by CaseCourtReportsController#save_report when it attaches the .docx.
  it "signs an upload request" do
    signer = Azure::Storage::Common::Core::Auth::SharedKey.new(account_name, access_key)
    uri = URI("https://#{account_name}.blob.core.windows.net/casa/report.docx?comp=block&blockid=abc")

    signature = signer.sign(:put, uri, {"Content-Type" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document"})

    expect(signature).to start_with("#{account_name}:")
  end

  # Exercised by active_storage/blobs/redirect#show when a user downloads the report.
  it "signs a download URL" do
    generator = Azure::Storage::Common::Core::Auth::SharedAccessSignature.new(account_name, access_key)
    uri = URI("https://#{account_name}.blob.core.windows.net/casa/report.docx")

    signed_uri = generator.signed_uri(uri, false, service: "b", permissions: "r", expiry: "2050-01-01T00:00:00Z")

    expect(signed_uri.query).to include("sig=")
  end
end
