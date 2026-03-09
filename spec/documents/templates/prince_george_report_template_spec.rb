# frozen_string_literal: true

require "rails_helper"
require "zip"
require "rexml/document"

RSpec.describe "Prince George report template" do
  let(:template_path) { Rails.root.join("app/documents/templates/prince_george_report_template.docx").to_s }
  let(:w_ns) { "http://schemas.openxmlformats.org/wordprocessingml/2006/main" }

  def extract_document_xml(docx_path)
    Zip::File.open(docx_path) do |zip|
      entry = zip.find_entry("word/document.xml")
      REXML::Document.new(entry.get_input_stream.read)
    end
  end

  def find_contacts_table(doc)
    tables = REXML::XPath.match(doc, "//w:tbl", "w" => w_ns)
    tables.find do |tbl|
      text = ""
      REXML::XPath.each(tbl, ".//w:t", "w" => w_ns) { |t| text += t.text.to_s }
      text.include?("Contact Dates")
    end
  end

  describe "contacts table column widths" do
    it "allocates more width to the Contact Dates column than Name or Title columns" do
      doc = extract_document_xml(template_path)
      table = find_contacts_table(doc)
      expect(table).not_to be_nil, "Could not find contacts table in template"

      grid_cols = REXML::XPath.match(table, ".//w:tblGrid/w:gridCol", "w" => w_ns)
      expect(grid_cols.length).to eq(3)

      widths = grid_cols.map { |col| col.attributes["w:w"].to_i }
      name_width, title_width, dates_width = widths

      expect(dates_width).to be > name_width, "Contact Dates column (#{dates_width}) should be wider than Name column (#{name_width})"
      expect(dates_width).to be > title_width, "Contact Dates column (#{dates_width}) should be wider than Title column (#{title_width})"
      expect(dates_width).to be >= 5760, "Contact Dates column should be at least 4 inches (5760 twips), got #{dates_width}"
    end

    it "preserves the total table width" do
      doc = extract_document_xml(template_path)
      table = find_contacts_table(doc)
      expect(table).not_to be_nil, "Could not find contacts table in template"

      grid_cols = REXML::XPath.match(table, ".//w:tblGrid/w:gridCol", "w" => w_ns)
      total = grid_cols.sum { |col| col.attributes["w:w"].to_i }

      expect(total).to eq(9606), "Total table width should be 9606 twips (original width), got #{total}"
    end
  end
end
