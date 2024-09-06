module FillInCaseContactFields
  DETAILS_ID = "#contact-form-details"
  NOTES_ID = "#contact-form-notes"
  TOPIC_VALUE_CLASS = ".contact-topic-answer-input"
  TOPIC_SELECT_CLASS = ".contact-topic-id-select"
  REIMBURSEMENT_ID = "#contact-form-reimbursement"
  EXPENSE_AMOUNT_CLASS = ".expense-amount-input"
  EXPENSE_DESCRIBE_CLASS = ".expense-describe-input"

  # @param case_numbers [Array[String]]
  # @param contact_types [Array[String]]
  # @param contact_made [Boolean]
  # @param medium [String]
  # @param occurred_on [String], date in the format MM/dd/YYYY
  # @param hours [Integer]
  # @param minutes [Integer]
  def fill_in_contact_details(
    contact_made: true, medium: "In Person", occurred_on: Time.zone.today, hours: nil, minutes: nil,
    case_numbers: [], contact_types: [], contact_topics: []
  )
    within DETAILS_ID do
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
    end

    within NOTES_ID do
      # previously answered on separate page... consolidate somehow...
      Array.wrap(contact_topics).each do |topic|
        click_on "Add Note"
        answer_topic_unscoped topic, nil
      end
    end
  end
  alias_method :complete_details_page, :fill_in_contact_details

  def fill_in_notes(notes: nil, contact_topic_answers: [], topic_answers_attributes: [])
    within NOTES_ID do
      Array.wrap(topic_answers_attributes).each do |attributes|
        answer_topic_unscoped attributes[:question], attributes[:answer], attributes[:index].presence
      end

      if notes.present?
        click_on "Add Note"
        answer_topic_unscoped "Additional Notes", notes
      end

      return if topic_answers_attributes.any?

      # needs topics to already be added & selected (via complete_details_page)
      contact_topic_answers = Array.wrap(contact_topic_answers)
      if contact_topic_answers.any?
        contact_topic_answers.each_with_index do |answer, index|
          answer_topic_unscoped(nil, answer, index:)
        end
      end
    end
  end
  alias_method :complete_notes_page, :fill_in_notes

  # @param miles [Integer]
  # @param want_reimbursement [Boolean]
  # @param address [String]
  def fill_in_mileage(miles: 0, want_reimbursement: false, address: nil)
    within REIMBURSEMENT_ID do
      check_reimbursement(want_reimbursement)
      return unless want_reimbursement

      fill_in "case_contact_miles_driven", with: miles if miles.present?
      fill_in "case_contact_volunteer_address", with: address if address
    end
  end
  alias_method :fill_in_expenses_page, :fill_in_mileage

  def choose_medium(medium)
    choose medium if medium
  end

  def check_reimbursement(want_reimbursement = true)
    if want_reimbursement
      check "Request travel or other reimbursement"
    else
      uncheck "Request travel or other reimbursement"
    end
  end

  def fill_expense_fields(amount, describe, index: nil)
    within REIMBURSEMENT_ID do
      amount_field = index.present? ? all(EXPENSE_AMOUNT_CLASS)[index] : all(EXPENSE_AMOUNT_CLASS).last
      describe_field = index.present? ? all(EXPENSE_DESCRIBE_CLASS)[index] : all(EXPENSE_DESCRIBE_CLASS).last
      amount_field.fill_in(with: amount) if amount
      describe_field.fill_in(with: describe) if describe
    end
  end

  def answer_topic(question, answer, index: nil)
    within NOTES_ID do
      answer_topic_unscoped(question, answer, index:)
    end
  end

  private

  # use when already 'within' notes div
  def answer_topic_unscoped(question, answer, index: nil)
    topic_select = index.present? ? all(TOPIC_SELECT_CLASS)[index] : all(TOPIC_SELECT_CLASS).last
    answer_field = index.present? ? all(TOPIC_VALUE_CLASS)[index] : all(TOPIC_VALUE_CLASS).last
    topic_select.select(question) if question
    answer_field.fill_in(with: answer) if answer
  end
end

RSpec.configure do |config|
  config.include FillInCaseContactFields, type: :system
end
