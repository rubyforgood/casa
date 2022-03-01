module Ext
  module PdfForms
    #
    # Fill form using FDF file directly
    #
    def fill_form_with_fdf(template, destination, fdf_path, fill_options = {}, flatten:)
      args = pdftk_arguments(template, destination, fdf_path, flatten: flatten)

      result = call_pdftk(*append_options(args, fill_options))

      if !File.readable?(destination) || File.size(destination).zero?
        raise ::PdfForms::PdftkError, "failed to fill form with command\n#{pdftk} #{args.flatten.compact.join " "}\ncommand output was:\n#{result}"
      end
    end

    private

    def pdftk_arguments(template, destination, fdf_path, flatten:)
      q_template = normalize_path(template)
      q_destination = normalize_path(destination)
      q_form_data = normalize_path(fdf_path)

      args = [q_template, "fill_form", q_form_data, "output", q_destination]
      args << "flatten" if flatten
      args
    end
  end
end

PdfForms::PdftkWrapper.include(Ext::PdfForms)
