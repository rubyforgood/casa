# Calculate values when using case contact parameters
class CaseContactParameters < SimpleDelegator
  def initialize(params)
    new_params =
      params.require(:case_contact).permit(
        :duration_minutes,
        :occurred_at,
        :contact_made,
        :medium_type,
        :miles_driven,
        :want_driving_reimbursement,
        :notes,
        :status,
        :volunteer_address,
        contact_type_ids: [],
        draft_case_ids: [],
        metadata: %i[create_another],
        additional_expenses_attributes: %i[id other_expense_amount other_expenses_describe _destroy],
        contact_topic_answers_attributes: %i[id value selected]
      )
    if params.dig(:case_contact, :duration_minutes)
      new_params[:duration_minutes] = convert_duration_minutes(params)
    end
    if params.dig(:case_contact, :miles_driven)
      new_params[:miles_driven] = convert_miles_driven(params)
    end
    if params.dig(:case_contact, :metadata, :create_another)
      new_params[:metadata][:create_another] =
        ActiveRecord::Type::Boolean.new.cast params[:case_contact][:metadata][:create_another]
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
