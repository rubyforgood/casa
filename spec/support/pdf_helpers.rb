# module PdfHelpers
#   def pdf_escape(string)
#     CGI.escapeHTML(string)
#   end
#
#   def to_pdf_string(string)
#     tempfile = Rails.root.join("tmp", "#{Time.zone.now.strftime('%Y%m%d%H%M%S%L')}-tmp.pdf")
#
#     Prawn::Document.generate(tempfile) { text(string) }
#
#     pdf_string = File.read(tempfile)
#     File.delete(tempfile)
#     pdf_string
#   end
#
#   def from_pdf_string(pdf_string)
#     PDF::Reader.new(StringIO.new(pdf_string))
#   end
#
#   def all_text_from_pdf_string(pdf_string)
#     from_pdf_string(pdf_string).pages.map(&:text).map(&:squish).join("\n")
#   end
#
#   def stub_pdf_generation
#     allow(PdfRenderer).to receive(:pdf_from_html).and_return(File.read("spec/fixtures/files/dummy.pdf"))
#   end
#
#   def html_pdf_generation
#     allow(PdfRenderer).to receive(:pdf_from_html) { |args| "#{args[:header]}\n#{args[:body]}\n#{args[:footer]}" }
#   end
# end
#
# RSpec.configure do |config|
#   config.include PdfHelpers
# end
