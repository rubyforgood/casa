# Calculate values when using case contact parameters
class CaseContactParameters < SimpleDelegator
  def initialize(params)
    params = normalize_params(params)
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

    super(new_params)
  end

  private

  def normalize_params(params)
    if params.dig(:case_contact, :metadata)
      params[:case_contact][:metadata] = convert_metadata(params[:case_contact][:metadata])
    end
    if params.dig(:case_contact, :duration_minutes)
      params[:case_contact][:duration_minutes] = convert_duration_minutes(params)
    end
    if params.dig(:case_contact, :miles_driven)
      params[:case_contact][:miles_driven] = convert_miles_driven(params)
    end

    params
  end

  def convert_metadata(metadata)
    if metadata["create_another"]
      metadata["create_another"] = ActiveRecord::Type::Boolean.new.cast metadata["create_another"]
    end
    metadata
  end

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
