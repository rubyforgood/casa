# Calculate values when using case contact parameters
class CaseContactParameters < SimpleDelegator
  def initialize(params, creator: nil)
    duration_minutes = convert_duration_minutes(params)
    miles_driven = convert_miles_driven(params)

    new_params =
      params.require(:case_contact).permit(
        :duration_minutes,
        :occurred_at,
        :contact_made,
        :medium_type,
        :miles_driven,
        :want_driving_reimbursement,
        :reimbursement_complete,
        :notes,
        :status,
        case_contact_contact_type_attributes: [:contact_type_id],
        additional_expense_attributes: [:id, :other_expense_amount, :other_expenses_describe],
        casa_case_attributes: [:id, volunteers_attributes: [:id, address_attributes: [:id, :content]]]
      )
    new_params[:duration_minutes] = duration_minutes
    new_params[:miles_driven] = miles_driven
    if creator
      new_params[:creator] = creator
    end

    super(new_params)
  end

  private

  def convert_duration_minutes(params)
    duration_hours = params[:case_contact][:duration_hours].to_i
    converted_duration_hours = duration_hours * 60
    duration_minutes = params[:case_contact][:duration_minutes].to_i
    converted_duration_hours + duration_minutes
  end

  def convert_miles_driven(params)
    miles_driven = params[:case_contact][:miles_driven]
    miles_driven.to_i
  end

  private

  def params
    __getobj__
  end
end
