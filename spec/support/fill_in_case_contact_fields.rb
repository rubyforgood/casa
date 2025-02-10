module FillInCaseContactFields
  DETAILS_ID = "#contact-form-details"
  NOTES_ID = "#contact-form-notes"
  TOPIC_VALUE_CLASS = ".contact-topic-answer-input"
  TOPIC_SELECT_CLASS = ".contact-topic-id-select"
  REIMBURSEMENT_ID = "#contact-form-reimbursement"
  EXPENSE_AMOUNT_CLASS = ".expense-amount-input"
  EXPENSE_DESCRIBE_CLASS = ".expense-describe-input"

  def fill_in_contact_details(case_numbers: [], contact_types: [], contact_made: true,
    medium: "In Person", occurred_on: Time.zone.today, hours: nil, minutes: nil)
    within DETAILS_ID do
      within "#draft-case-id-selector" do
        if case_numbers.nil?
          all(:element, "a", title: "Remove this item").each(&:click)
        end

        if case_numbers.present?
          find(".ts-control").click

          Array.wrap(case_numbers).each_with_index do |case_number, index|
            checkbox_for_case_number = first("span", text: case_number).sibling("input")
            checkbox_for_case_number.click unless checkbox_for_case_number.checked?
          end

          find(".ts-control").click
        end
      end

      fill_in "case_contact_occurred_at", with: occurred_on if occurred_on

      if contact_types.present?
        contact_types.each do |contact_type|
          check contact_type
        end
      elsif !contact_types.nil?
        contact_type = ContactType.first
        check contact_type.name
      end

      choose medium if medium

      if contact_made
        check "Contact was made"
      else
        uncheck "Contact was made"
      end

      fill_in "case_contact_duration_hours", with: hours if hours
      fill_in "case_contact_duration_minutes", with: minutes if minutes
    end
  end
  alias_method :complete_details_page, :fill_in_contact_details

  def fill_in_notes(notes: nil, contact_topic_answers_attrs: [])
    within NOTES_ID do
      Array.wrap(contact_topic_answers_attrs).each_with_index do |attributes, index|
        click_on "Add Another Discussion Topic" if index > 0
        answer_topic_unscoped attributes[:question], attributes[:answer]
      end

      if notes.present?
        fill_in "Additional Notes", with: notes
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
    topic_select = index.nil? ? all(TOPIC_SELECT_CLASS).last : all(TOPIC_SELECT_CLASS)[index]
    answer_field = index.nil? ? all(TOPIC_VALUE_CLASS).last : all(TOPIC_VALUE_CLASS)[index]
    topic_select.select(question) if question
    answer_field.fill_in(with: answer) if answer
  end
end

RSpec.configure do |config|
  config.include FillInCaseContactFields, type: :system
end
