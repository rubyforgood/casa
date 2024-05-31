class VolunteerParameters < UserParameters
  include PhoneNumberHelper

  def initialize(params)
    params[:volunteer][:phone_number] = params[:volunteer][:phone_number].present? ? strip_unnecessary_characters(params[:volunteer][:phone_number]) : ""

    super(params, :volunteer)
  end
end
