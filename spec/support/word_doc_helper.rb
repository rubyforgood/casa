module WordDocHelper
  # Get the contents of an XML file in the word document as a string
  # @example
  #
  #   find_in_docx("/case_court_reports/CINA-10.docx", "word/header2.xml") do |xml_as_string|
  #     puts xml_as_string
  #   end
  #
  # @param [String] link The link to the generated word document
  # @param [String] path The path to the XML file in the word document
  # @return [String] The contents of the file specified by path in the word document
  #
  def find_in_docx(link, path)
    get link

    Tempfile.create("court_report.zip", "tmp") do |file|
      file << response.body

      Zip::File.open(file.path) do |docx_extracted|
        return docx_extracted.find_entry(path).get_input_stream.read.force_encoding("UTF-8")
      end
    end
  end
end
