# frozen_string_literal: true

require "rails_helper"

RSpec.describe FdfInputsService, type: :service do
  describe ".clean" do
    context "when the string is nil" do
      it "returns nil" do
        expect(FdfInputsService.clean("")).to be_nil
        expect(FdfInputsService.clean("  ")).to be_nil
        expect(FdfInputsService.clean(nil)).to be_nil
      end
    end

    it "returns the escaped string" do
      expect(FdfInputsService.clean("hello world")).to eq("hello world")
      expect(FdfInputsService.clean("(test)")).to eq("\\(test\\)")
      expect(FdfInputsService.clean("path\\to\\file")).to eq("path\\\\to\\\\file")
      expect(FdfInputsService.clean("(a\\b)")).to eq("\\(a\\\\b\\)")
      expect(FdfInputsService.clean("((a))")).to eq("\\(\\(a\\)\\)")
      expect(FdfInputsService.clean("\\(test\\)")).to eq("\\\\\\(test\\\\\\)")
    end
  end

  describe "#write_to_file" do
    it "calls PdfForms with the given arguments and returns a file" do
      inputs = {name: "Bob Cat"}
      pdf_template_path = "/path/to/template.pdf"
      basename = "test_file"

      fake_pdf_forms = double("PdfForms")
      allow(PdfForms).to receive(:new).and_return(fake_pdf_forms)
      allow(fake_pdf_forms).to receive(:fill_form_with_fdf)

      service = FdfInputsService.new(
        inputs: inputs,
        pdf_template_path: pdf_template_path,
        basename: basename
      )

      result = service.write_to_file

      expect(fake_pdf_forms).to have_received(:fill_form_with_fdf) do |template, output_path, fdf_path, flatten|
        expect(template).to eq(pdf_template_path)
        expect(output_path).to be_a(String)
        expect(File.exist?(output_path)).to be(true)
        expect(fdf_path).to be_a(String)
        expect(File.exist?(fdf_path)).to be(true)
        expect(flatten).to eq(flatten: true)
      end

      expect(result).to be_a(Tempfile)
      expect(File.exist?(result.path)).to be(true)
    end
  end
end
