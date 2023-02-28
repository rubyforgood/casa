module FillOutMinimumRequiredFields
  def fill_out_case_contact_minimum
    check "School"
    within "#enter-contact-details" do
      choose "Yes"
    end
    choose "Video"

    fill_in "case-contact-duration-hours-display", with: "1"
  end
end

RSpec.configure do |config|
  config.include FillOutMinimumRequiredFields, type: :system
end
