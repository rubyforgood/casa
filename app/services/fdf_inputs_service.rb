class FdfInputsService
  FDF_ERB_TEMPLATE_PATH = ["data", "inputs_fdf.erb"].freeze

  def self.clean(str)
    return unless str.present?
    str
      .to_s
      .gsub(/[)(\\]/, '\\\\\0')
  end

  def initialize(inputs:, pdf_template_path:, basename:)
    @inputs = inputs
    @pdf_template_path = pdf_template_path
    @basename = basename
  end

  def write_to_file(flatten: true)
    file ||= Tempfile.new(basename)
    with_fdf_tempfile do |fdf|
      pdftk = PdfForms.new
      pdftk.fill_form_with_fdf(pdf_template_path, file.path, fdf.path, flatten: flatten)
    end
    file
  end

  private

  attr_reader :inputs, :pdf_template_path, :basename

  def with_fdf_tempfile
    Tempfile.open(basename) do |fdf|
      fdf.puts ERB.new(fdf_template).result(binding)
      fdf.rewind
      yield(fdf)
    end
  end

  def fdf_template
    File.read(Rails.root.join(*FDF_ERB_TEMPLATE_PATH))
  end
end
