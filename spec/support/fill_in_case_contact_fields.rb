module FillInCaseContactFields
  # @param case_numbers [Array[String]]
  # @param contact_types [Array[String]]
  # @param contact_made [Boolean]
  # @param medium [String]
  # @param occurred_on [String], date in the format MM/dd/YYYY
  # @param hours [Integer]
  # @param minutes [Integer]
  def complete_details_page(contact_made:, medium: nil, occurred_on: nil, hours: nil, minutes: nil, case_numbers: [], contact_types: [])
    case_numbers.each do |case_number|
      check case_number
    end

    contact_types.each do |contact_type|
      check contact_type
    end

    within "#enter-contact-details" do
      choose contact_made ? "Yes" : "No"
    end
    choose medium if medium
    fill_in "case_contact_occurred_at", with: occurred_on if occurred_on

    fill_in "case_contact_duration_hours", with: hours if hours
    fill_in "case_contact_duration_minutes", with: minutes if minutes

    click_on "Save and continue"
  end

  # @param notes [String]
  def complete_notes_page(notes: "", click_continue: true)
    fill_in "Notes", with: notes

    click_on "Save and continue" if click_continue
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
