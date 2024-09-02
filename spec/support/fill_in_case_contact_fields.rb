module FillInCaseContactFields
  REIMBURSEMENT_ID = "#contact-form-reimbursement"
  EXPENSE_AMOUNT_CLASS = ".expense-amount-input"
  EXPENSE_DESCRIBE_CLASS = ".expense-describe-input"

  def fill_expense_fields(amount, describe, index: nil)
    within REIMBURSEMENT_ID do
      amount_field = index.present? ? all(EXPENSE_AMOUNT_CLASS)[index] : all(EXPENSE_AMOUNT_CLASS).last
      describe_field = index.present? ? all(EXPENSE_DESCRIBE_CLASS)[index] : all(EXPENSE_DESCRIBE_CLASS).last
      amount_field.fill_in(with: amount) if amount
      describe_field.fill_in(with: describe) if describe
    end
  end

  # @param case_numbers [Array[String]]
  # @param contact_types [Array[String]]
  # @param contact_made [Boolean]
  # @param medium [String]
  # @param occurred_on [String], date in the format MM/dd/YYYY
  # @param hours [Integer]
  # @param minutes [Integer]
  def complete_details_page(
    contact_made: true, medium: "In Person", occurred_on: Time.zone.today, hours: nil, minutes: nil,
    case_numbers: [], contact_types: [], contact_topics: []
  )
    within find("#draft-case-id-selector") do
      find(".ts-control").click
    end

    Array.wrap(case_numbers).each do |case_number|
      checkbox_for_case_number = find("span", text: case_number).sibling("input")
      checkbox_for_case_number.click unless checkbox_for_case_number.checked?
    end

    within find("#draft-case-id-selector") do
      find(".ts-control").click
    end

    Array.wrap(case_numbers).each do |case_number|
      # check case_numbers have been selected
      expect(page).to have_text case_number
    end

    fill_in "case_contact_occurred_at", with: occurred_on if occurred_on

    contact_types.each do |contact_type|
      check contact_type
    end

    choose medium if medium

    within "#enter-contact-details" do
      if contact_made
        check "Contact was made"
      else
        uncheck "Contact was made"
      end
    end

    fill_in "case_contact_duration_hours", with: hours if hours
    fill_in "case_contact_duration_minutes", with: minutes if minutes

    contact_topics.each do |contact_topic|
      check contact_topic
    end
  end

  def choose_medium(medium)
    choose medium if medium
  end

  # @param notes [String]
  def complete_notes_page(notes: nil, contact_topic_answers: [])
    if notes.present?
      click_on "Add Note"
      select "Additional Notes"
      fill_in "Discussion Notes", with: notes
    end

    # debugger

    if contact_topic_answers.any?
      contact_topic_answers.each do |answer|
        click_on "Add Note"
        # change to contact topic id value selection...
        select answer[:question]

        fill_in "Discussion Notes", with: answer[:value]
      end
    end
  end

  # This intentionally does not submit the form
  # @param miles [Integer]
  # @param want_reimbursement [Boolean]
  # @param address [String]
  def fill_in_expenses_page(miles: 0, want_reimbursement: false, address: nil)
    fill_in "case_contact_miles_driven", with: miles

    if want_reimbursement
      check "Request travel or other reimbursement"
    else
      uncheck "Request travel or other reimbursement"
    end

    fill_in "case_contact_volunteer_address", with: address if address
  end
end

RSpec.configure do |config|
  config.include FillInCaseContactFields, type: :system
end
