require "rails_helper"

RSpec.describe FileImporter do
  let!(:import_user) { create(:casa_admin) }
  let(:import_file_path) { Rails.root.join("spec", "fixtures", "generic.csv") }
  let(:file_importer) { FileImporter.new(import_file_path, import_user.casa_org.id) }

  describe "import" do
    it "assumes headers" do
      file_importer.import { |f| true }
      expect(file_importer.number_imported).to eq(2)
    end

    it "resets the count of how many have been imported, each time" do
      file_importer.import { |f| true }
      file_importer.import { |f| true }
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
        file_importer.import do |row|
          raise "Something bad"
        end
      }.not_to raise_error
      expect(file_importer.failed_imports.size).to eq(2)
    end
  end
end
