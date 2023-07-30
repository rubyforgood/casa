module DownloadHelpers
  TIMEOUT = 10
  PATH = Rails.root.join("tmp/downloads")

  def downloads
    Dir[PATH.join("*")]
  end

  def download
    downloads.first
  end

  def download_content
    wait_for_download
    File.read(download)
  end

  def download_docx
    wait_for_download
    Docx::Document.open(download)
  end

  def header_text(download_docx)
    zip = download_docx.zip
    files = zip.glob("word/header*.xml").map { |h| h.name }
    filename_and_contents_pairs = files.map do |file|
      simple_file_name = file.sub(/^word\//, "").sub(/\.xml$/, "")
      [simple_file_name, Nokogiri::XML(zip.read(file))]
    end

    filename_and_contents_pairs.map { |name, doc| doc.text }.join("\n")
  end

  def table_text(download_docx)
    download_docx.tables.map{|t| t.rows.map(&:cells).flatten.map(&:to_s)}.flatten
  end

  def download_file_name
    File.basename(download)
  end

  def wait_for_download
    Timeout.timeout(TIMEOUT) do
      sleep 0.1 until downloaded?
    end
  end

  def downloaded?
    !downloading? && downloads.any?
  end

  def downloading?
    downloads.grep(/\.crdownload$/).any?
  end

  def clear_downloads
    FileUtils.rm_f(downloads)
  end
end
