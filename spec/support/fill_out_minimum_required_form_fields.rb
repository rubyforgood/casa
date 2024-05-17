module FillOutMinimumRequiredFields
  def fill_out_minimum_required_fields_for_case_contact_form
    check "School"
    within "#enter-contact-details" do
      choose "Yes"
    end
    choose "Video"

    fill_in "case_contact_duration_hours", with: "1"
  end
end

RSpec.configure do |config|
  config.include FillOutMinimumRequiredFields, type: :system
end
