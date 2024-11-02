module UploadHelpers
  def upload_file(file)
    content = File.read(file)
    tempfile = Tempfile.open
    tempfile.write content
    tempfile.rewind

    Rack::Test::UploadedFile.new(tempfile)
  end
end
