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
        contact_topic_answers_attributes: %i[id contact_topic_id value selected _destroy]
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

    normalize_topic_answers_and_notes(params)
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

  def normalize_topic_answers_and_notes(params)
    # Should never be used after params.require/permit - uses `to_unsafe_h`
    # allows form submission of contact.notes as a 'topic-less' topic answer (contact_topic_id: "")
    return params unless params[:case_contact][:contact_topic_answers_attributes]

    notes = ""
    notes << params[:case_contact][:notes] if params[:case_contact][:notes]

    answers_attributes = params[:case_contact][:contact_topic_answers_attributes].to_unsafe_h
    no_topic_answers = answers_attributes&.filter do |_k, v|
      # may be sent as id vs. contact_topic_id somewhere
      # ! may be both missing due to accepts_nest_attributes, update_only: true
      v[:contact_topic_id].blank? && v[:id].blank?
    end
    no_topic_answers&.each do |k, v|
      notes << v["value"]
      params[:case_contact][:contact_topic_answers_attributes].delete(k)
    end

    params[:case_contact][:notes] = notes

    params
  end

  private

  def params
    __getobj__
  end
end
