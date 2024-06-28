module FillInCaseContactFields
  # @param case_numbers [Array[String]]
  # @param contact_types [Array[String]]
  # @param contact_made [Boolean]
  # @param medium [String]
  # @param occurred_on [String], date in the format MM/dd/YYYY
  # @param hours [Integer]
  # @param minutes [Integer]
  def complete_details_page(contact_made:, medium: nil, occurred_on: nil, hours: nil, minutes: nil, case_numbers: [], contact_types: [], contact_topics: [])
    within find("#draft-case-id-selector") do
      find(".ts-control").click
    end

    case_numbers.each do |case_number|
      checkbox_for_case_number = find("span", text: case_number).sibling("input")
      checkbox_for_case_number.click unless checkbox_for_case_number.checked?
    end

    within find("#draft-case-id-selector") do
      find(".ts-control").click
    end

    within find("#contact-type-id-selector") do
      find(".ts-control").click
    end

    contact_types.each do |contact_type|
      find("span", text: contact_type).click
    end

    within find("#contact-type-id-selector") do
      find(".ts-control").click
    end

    within "#enter-contact-details" do
      choose contact_made ? "Yes" : "No"
    end
    choose medium if medium
    fill_in "case_contact_occurred_at", with: occurred_on if occurred_on
    fill_in "case_contact_duration_hours", with: hours if hours
    fill_in "case_contact_duration_minutes", with: minutes if minutes

    contact_topics.each do |contact_topic|
      check contact_topic
    end

    click_on "Save and Continue"
  end

  def choose_medium(medium, click_continue: true)
    choose medium if medium

    click_on "Save and Continue" if click_continue
  end

  # @param notes [String]
  def complete_notes_page(notes: "", click_continue: true)
    fill_in "Additional notes", with: notes

    click_on "Save and Continue" if click_continue
  end

  # This intentionally does not submit the form
  # @param miles [Integer]
  # @param want_reimbursement [Boolean]
  # @param address [String]
  def fill_in_expenses_page(miles: 0, want_reimbursement: false, address: nil)
    fill_in "case_contact_miles_driven", with: miles

    within ".want-driving-reimbursement" do
      choose want_reimbursement ? "Yes" : "No"
    end

    fill_in "case_contact_volunteer_address", with: address if address
  end
end

RSpec.configure do |config|
  config.include FillInCaseContactFields, type: :system
end
