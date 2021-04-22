module WordDocHelper
  # Get the contents of an XML file in the word document as a string
  # @example
  #
  #   get_docx_subfile_contents(docx_file_data, "word/header2.xml")
  #
  # @param [String] docx The contents of the docx file
  # @param [String] path The path to the XML file in the word document
  # @return [String] The contents of the file specified by path in the word document
  #
  def get_docx_subfile_contents(docx, path)
    Tempfile.create("court_report.zip", "tmp") do |file|
      file << docx

      Zip::File.open(file.path) do |docx_extracted|
        return docx_extracted.find_entry(path).get_input_stream.read.force_encoding("UTF-8")
      end
    end
  end
end
