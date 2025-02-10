require "rails_helper"

RSpec.describe FileImporter do
  let!(:import_user) { build_stubbed(:casa_admin) }
  let(:import_file_path) { file_fixture "generic.csv" }
  let(:file_importer) { FileImporter.new(import_file_path, import_user.casa_org.id, "something", ["header"]) }

  describe "import" do
    it "assumes headers" do
      file_importer.import { |_f| true }
      expect(file_importer.number_imported).to eq(2)
    end

    it "resets the count of how many have been imported, each time" do
      file_importer.import { |_f| true }
      file_importer.import { |_f| true }
      expect(file_importer.number_imported).to eq(2)
    end

    it "yields to a block" do
      names = []
      file_importer.import do |row|
        names << row
      end
      expect(names.size).to eq(2)
    end

    it "captures errors" do
      expect {
        file_importer.import do |_row|
          raise "Something bad"
        end
      }.not_to raise_error
      expect(file_importer.failed_imports.size).to eq(2)
    end

    it "returns hash with expected attributes" do
      result = file_importer.import { |_f| true }
      expect(result.keys).to contain_exactly(:type, :message, :exported_rows)
    end

    it "returns an error if file has no rows" do
      no_row_path = file_fixture "no_rows.csv"
      no_row_importer = FileImporter.new(no_row_path, import_user.casa_org.id, "something", ["header"])
      expect(no_row_importer.import[:message]).eql?(FileImporter::ERR_NO_ROWS)
    end
  end
end
