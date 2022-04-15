class DocxInspector
  IGNORED_FILE_LIST = {"fontTable" => 0, "numbering" => 0, "settings" => 0, "styles" => 0, "webSettings" => 0}
  DOCX_WORD_DIRECTORY_FILENAME_CAPTURE_PATTERN = /^word\/([^\/]*)\.xml/ # Capture the file name of a file in the docx's word/ directory (not recursive)

  def initialize(docx_contents: nil, docx_path: nil)
    if !docx_contents.nil?
      docx_as_zip = get_docx_as_zip_object(docx_contents: docx_contents)
    elsif !docx_path.nil?
      docx_as_zip = get_docx_as_zip_object(docx_path: docx_path)
    else
      raise ArgumentError.new("Insufficient parameters. Either docx_contents or docx_path is required.")
    end

    @word_lists_by_document_section = {document: [], endnotes: [], footnotes: [], footer: [], header: []}

    get_docx_readable_text_XML_files(docx_as_zip).each do |file|
      file_name = file.name.match(DOCX_WORD_DIRECTORY_FILENAME_CAPTURE_PATTERN).captures[0]
      viewable_strings = get_displayed_text_list(get_XML_object(file))

      case file_name
        when /^document/
          @word_lists_by_document_section[:document].concat(viewable_strings)
        when /^endnotes/
          @word_lists_by_document_section[:endnotes].concat(viewable_strings)
        when /^footnotes/
          @word_lists_by_document_section[:footnotes].concat(viewable_strings)
        when /^footer/
          @word_lists_by_document_section[:footer].concat(viewable_strings)
        when /^header/
          @word_lists_by_document_section[:header].concat(viewable_strings)
      end
    end

    @word_lists_by_document_section.each do |section, word_list|
      sort_string_list_by_length_ascending(word_list)
    end
  end

  def get_word_list_all
    sort_string_list_by_length_ascending(
      @word_lists_by_document_section[:document] +
      @word_lists_by_document_section[:endnotes] +
      @word_lists_by_document_section[:footnotes] +
      @word_lists_by_document_section[:footer] +
      @word_lists_by_document_section[:header]
    )
  end

  def get_word_list_document
    @word_lists_by_document_section[:document]
  end

  def get_word_list_endnotes
    @word_lists_by_document_section[:endnotes]
  end

  def get_word_list_footnotes
    @word_lists_by_document_section[:footnotes]
  end

  def get_word_list_footer
    @word_lists_by_document_section[:footer]
  end

  def get_word_list_header
    @word_lists_by_document_section[:header]
  end

  def word_list_all_contains?(str)
    word_list_contains_str?(get_word_list_all, str)
  end

  def word_list_document_contains?(str)
    word_list_contains_str?(get_word_list_document, str)
  end

  def word_list_endnotes_contains?(str)
    word_list_contains_str?(get_word_list_endnotes, str)
  end

  def word_list_footnotes_contains?(str)
    word_list_contains_str?(get_word_list_footnotes, str)
  end

  def word_list_footer_contains?(str)
    word_list_contains_str?(get_word_list_footer, str)
  end

  def word_list_header_contains?(str)
    word_list_contains_str?(get_word_list_header, str)
  end

  private

  def get_displayed_text_list(xml_object)
    xml_object.xpath("//w:t/text()").filter_map do |word_text_element|
      stripped_text = word_text_element.text.strip
      stripped_text if stripped_text.length > 0
    end
  end

  def get_docx_as_zip_object(docx_contents: nil, docx_path: nil)
    if !docx_contents.nil?
      Zip::File.open_buffer(docx_contents)
    elsif !docx_path.nil?
      Zip::File.open(docx_path)
    else
      raise ArgumentError.new("Insufficient parameters. Either docx_contents or docx_path is required.")
    end
  end

  def get_docx_readable_text_XML_files(docx_as_zip)
    docx_as_zip.entries.select do |entry|
      entry_name = entry.name
      is_ignored_file = false
      xml_file_in_word_match = entry_name.match(DOCX_WORD_DIRECTORY_FILENAME_CAPTURE_PATTERN)

      unless xml_file_in_word_match.nil?
        xml_file_name = xml_file_in_word_match.captures[0]
        is_ignored_file = !IGNORED_FILE_LIST[xml_file_name].nil?
      end

      !(xml_file_in_word_match.nil? || is_ignored_file)
    end
  end

  def get_XML_object(xml_file_as_docx_zip_entry)
    Nokogiri::XML(xml_file_as_docx_zip_entry.get_input_stream.read)
  end

  def search_string_list_for_index_of_first_string_of_at_least_n_length(string_list_sorted_by_length, n)
    low = 0
    high = string_list_sorted_by_length.length - 1
    mid = (low + high) / 2

    while low < high
      if string_list_sorted_by_length[mid].length < n
        low = mid + 1
      else
        high = mid - 1
      end

      mid = (low + high) / 2
    end

    if string_list_sorted_by_length[mid].length < n
      if string_list_sorted_by_length.length - 1 == mid
        return nil
      else
        return mid + 1
      end
    end

    [0, mid].max
  end

  def sort_string_list_by_length_ascending(str_list)
    str_list.sort_by!(&:length)
  end

  def word_list_contains_str?(word_list, str)
    first_possible_word_containing_str_index = search_string_list_for_index_of_first_string_of_at_least_n_length(
      word_list,
      str.length
    )

    if first_possible_word_containing_str_index.nil?
      return false
    end

    word_list[first_possible_word_containing_str_index..(word_list.length - 1)].each do |word|
      if word.include?(str)
        return true
      end
    end

    false
  end
end
