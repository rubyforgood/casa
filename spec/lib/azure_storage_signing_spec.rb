# frozen_string_literal: true

require "rails_helper"
require "active_storage/service/azure_blob_service"

# Production stores every attachment on Azure (config.active_storage.service = :microsoft,
# service: AzureBlob). The azure-blob gem signs both uploads and download URLs with CGI.parse.
# Ruby 4.0's stdlib cgi ships only escape/unescape, so a full cgi gem must resolve — azure-blob
# declares it as a dependency, which pulls it back in (Rails 8 stopped doing so transitively).
# When that goes missing, every Active Storage read and write 500s in production while CI stays
# green, because the test environment uses Disk storage and never touches this code.
#
# This is the regression guard for the retired azure-storage-blob → azure-blob migration.
# See https://github.com/rubyforgood/casa/issues/7094 (and the earlier #7093).
RSpec.describe "Azure Storage request signing" do
  let(:service) do
    ActiveStorage::Service::AzureBlobService.new(
      storage_account_name: "casaaccount",
      storage_access_key: Base64.strict_encode64("not-a-real-key"),
      container: "casa"
    )
  end

  it "has the full CGI library, not Ruby 4.0's escape-only stdlib" do
    expect(CGI).to respond_to(:parse)
  end

  # Exercised by active_storage/blobs/redirect#show when a user downloads a court report.
  it "signs a private download URL locally, without hitting Azure" do
    url = service.url(
      "report.docx",
      expires_in: 5.minutes,
      filename: ActiveStorage::Filename.new("report.docx"),
      disposition: :attachment,
      content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    )

    expect(url).to start_with("https://casaaccount.blob.core.windows.net/casa/report.docx")
    expect(url).to include("sig=")
  end

  # Exercised whenever an attachment is uploaded (e.g. CaseCourtReportsController#save_report).
  it "signs a direct-upload URL locally, without hitting Azure" do
    url = service.url_for_direct_upload(
      "report.docx",
      expires_in: 5.minutes,
      content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
      content_length: 1024,
      checksum: "md5-checksum"
    )

    expect(url).to include("sig=")
  end
end
