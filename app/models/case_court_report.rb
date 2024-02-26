# frozen_string_literal: true

require "sablon"

class CaseCourtReport
  attr_reader :report_path, :context, :template

  def initialize(path_to_template:, context:)
    @context = context
    # NOTE: this is what is used for docx templates
    @template = Sablon.template(path_to_template)
  end

  def generate_to_string
    @template.render_to_string(@context)
  end
end
