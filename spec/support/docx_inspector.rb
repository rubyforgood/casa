class DocxInspector
  def initialize(docx_contents: nil, docx_path: nil)
    docx_file = nil

    if !docx_contents.nil?
      docx_file = store_docx_contents_in_tempfile(docx_contents)
    elsif !docx_path.nil?
      docx_file = File.open(docx_path, "r")
    else
      raise ArgumentError.new("Insufficient parameters. Either docx_contents or docx_path is required.")
    end

    @docx_zip_object = get_docx_as_zip_object(docx_file)

    puts get_docx_readable_text_XML_files
  end

  def contains_str?(str)
    # Sort w:t s by length and keep array on instance
  end

  private

  def get_displayed_text_list
  end

  def get_docx_as_zip_object(docx_file)
    Zip::File.open(docx_file.path)
  end

  def get_docx_readable_text_XML_files
    if @docx_zip_object.nil?
      raise "Required variable @docx_zip_object is uninitialized"
    end

    word_entries = @docx_zip_object.entries.select do |entry|
      entry.name =~ /^word\/[^\/]*\.xml/ # A file in the word/ directory not in a directory below word
    end

    puts word_entries
  end

  def get_XML_object(file_path)
  end

  def store_docx_contents_in_tempfile(docx_contents)
    Tempfile.create("court_report.zip", "tmp") do |file|
      file << docx_contents.force_encoding("UTF-8")

      return file
    end
  end
end
