module CsvExporterHelper
  TIMEOUT = 10

  def wait_for_csv_parse(model, result, fields)
    Timeout.timeout(TIMEOUT) do
      sleep 0.025 while not_include_fields?(model, result, fields)
    end
  end

  def not_include_fields?(model, result, fields)
    fields.collect do |f|
      result.include?(model.send(f))
    end.flatten.compact.uniq.include?(false)
  end
end
