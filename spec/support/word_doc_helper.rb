module WordDocHelper
  # This class is here so I can have private methods https://stackoverflow.com/a/424569
  class DocxInspector
    def initialize(docx_path)
      #Sort w:t s by length and keep array on instance
    end

    def contains_str?(str)
    end

    private

    def get_docx_as_directory()
    end

    def get_docx_readable_text_XML_file_paths(docx_word_directory)
    end

    def get_XML_object(file_path)
    end

    def get_displayed_text_list()
    end
  end

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
      file << docx.force_encoding("UTF-8")

      Zip::File.open(file.path) do |docx_extracted|
        return docx_extracted.find_entry(path).get_input_stream.read.force_encoding("UTF-8")
      end
    end
  end

  # Get the text contents of an XML file in the word document as a string, useful for checking inclusion
  #
  # This isn't fully fool-proof. DOCX does weird stuff with splitting up strings <w:p>lik</w:p><w:p>e this</w:p>
  # so some words may show up separated. If that's happening you can pass `true` for the :collapse argument
  # and it will render the above "likethis". This should satisfy sufficiently unique strings in test data.
  #
  # @example
  #
  #   get_docx_contents_as_string(docx_file_data)
  #
  # @param [String] docx The contents of the docx file
  # @param [Boolean] collapse Whether or not the contents should be fully condensed
  # @return [String] The contents with all XML markup removed
  #
  def get_docx_contents_as_string(docx, collapse: false)
    Tempfile.create("court_report.zip", "tmp") do |file|
      file << docx.force_encoding("UTF-8")

      xml_document = Zip::File.open(file.path) do |docx_extracted|
        docx_extracted.find_entry("word/document.xml").get_input_stream.read.force_encoding("UTF-8")
      end
      separate_with = collapse ? "" : "\n"
      xml_document.gsub(/<[^>]*>+/, "\n").gsub(/\n+/, separate_with)
    end
  end
end
