# Calculate values when using case contact parameters
class CaseContactParameters < SimpleDelegator
  def initialize(params)
    params =
      params.require(:case_contact).permit(
        :duration_minutes,
        :occurred_at,
        :contact_made,
        :medium_type,
        :miles_driven,
        :want_driving_reimbursement,
        :notes,
        case_contact_contact_type_attributes: [:contact_type_id]
        # additional_expense_attributes: [:id, :other_expense_amount, :other_expenses_describe]
      )
    params[:miles_driven] = params[:miles_driven].to_i
    super(params)
  end

  def with_creator(creator)
    params[:creator] = creator
    self
  end

  def with_converted_duration_minutes(duration_hours)
    converted_duration_hours = duration_hours * 60
    duration_minutes = params[:duration_minutes].to_i
    params[:duration_minutes] = converted_duration_hours + duration_minutes
    self
  end

  def with_converted_miles_driven(miles_driven)
    params[:miles_driven] = miles_driven.to_i
    self
  end

  private

  def params
    __getobj__
  end
end
