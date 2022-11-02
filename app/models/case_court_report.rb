# frozen_string_literal: true

require "sablon"

class CaseCourtReport
  attr_reader :report_path, :context, :template

  def initialize(args = {})
    @context = CaseCourtReportContext.new(args).context
    @template = Sablon.template(args[:path_to_template])
  end

  def generate_to_string
    @template.render_to_string(@context)
  end
end
