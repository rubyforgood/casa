require "rails_helper"
require "fileutils"
require "csv"

RSpec.describe FailedImportCsvService do
  let(:import_type) { "casa_case" }
  let(:user) { create(:casa_admin) }
  let(:csv_string) { "case_number,birth_month_year_youth\n12345,2001-04\n" }
  let(:user_id_hash) { Digest::SHA256.hexdigest(user.id.to_s)[0..15] }
  let(:csv_path) { Rails.root.join("tmp", import_type, "failed_rows_userid_#{user_id_hash}.csv") }

  subject(:service) { described_class.new(failed_rows: failed_rows, import_type: import_type, user: user) }

  before { FileUtils.rm_f(csv_path) }
  after { FileUtils.rm_f(csv_path) }

  def create_file(content: csv_string, mtime: Time.current)
    FileUtils.mkdir_p(File.dirname(csv_path))
    File.write(csv_path, content)
    File.utime(mtime.to_time, mtime.to_time, csv_path)
  end

  describe "#store" do
    context "when file is within size limit" do
      let(:failed_rows) { csv_string }

      it "writes the CSV content to the tmp file" do
        service.store

        expect(File.exist?(csv_path)).to be true
        expect(File.read(csv_path)).to eq csv_string
      end
    end

    context "when file exceeds size limit" do
      let(:failed_rows) { "a" * (described_class::MAX_FILE_SIZE_BYTES + 1) }

      it "logs a warning and stores a warning" do
        expect(Rails.logger).to receive(:warn).with(/CSV too large to save for user/)
        service.store

        expect(File.read(csv_path)).to match(/The file was too large to save/)
      end
    end
  end

  describe "#read" do
    let(:failed_rows) { '' }

    context "when file exists and has not expired" do
      before { create_file }

      it "returns the contents" do
        expect(service.read).to eq csv_string
      end
    end

    context "when file is expired" do
      let(:failed_rows) { 'The failed import file has expired. Please upload a new  CSV.' }
      before { create_file(mtime: 2.days.ago.to_time) }

      it "deletes the file and returns fallback message" do
        expect(File.exist?(csv_path)).to be true
        expect(service.read).to include("The failed import file has expired")
        expect(File.exist?(csv_path)).to be false
      end
    end

    context "when file never existed" do
      it "returns fallback message" do
        expect(service.read).to include("No failed import file found")
      end
    end
  end

  describe "#cleanup" do
    let(:failed_rows) { "" }

    context "when file exists" do
      before { create_file }

      it "removes the file" do
        expect(File.exist?(csv_path)).to be true
        expect(Rails.logger).to receive(:info).with(/Removing old failed rows CSV/)
        service.cleanup
        expect(File.exist?(csv_path)).to be false
      end
    end

    context "when file does not exist" do
      it "does nothing" do
        expect { service.cleanup }.not_to raise_error
      end
    end
  end
end
