module CourtDateParams

  private

  def sanitized_court_date_params(casa_case)
    params.require(:court_date).tap do |p|
      p[:case_court_orders_attributes]&.reject! do |k, _|
        p[:case_court_orders_attributes][k][:text].blank? && p[:case_court_orders_attributes][k][:implementation_status].blank?
      end

      p[:case_court_orders_attributes]&.each do |k, _|
        p[:case_court_orders_attributes][k][:casa_case_id] = casa_case.id
      end
    end
  end

  def court_date_params(casa_case)
    sanitized_court_date_params(casa_case).permit(
      :date,
      :hearing_type_id,
      :judge_id,
      :court_report_due_date,
      {case_court_orders_attributes: %i[text _destroy implementation_status id casa_case_id]}
    )
  end
end
