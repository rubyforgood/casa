class SvgSanitizerService
  class << self
    def sanitize(file)
      return file unless file&.content_type == "image/svg+xml"

      content = file.read
      content.force_encoding("UTF-8")
      document = Loofah.xml_document(content)
      safe_content = document.scrub!(scrubber).to_s
      File.write(file.path, safe_content)
      file.rewind
      file
    end

    private

    def scrubber
      Loofah::Scrubber.new do |node|
        node.remove if node.name == "script"
      end
    end
  end
end
