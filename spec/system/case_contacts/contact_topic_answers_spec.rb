require "rails_helper"

RSpec.describe "CaseContact form ContactTopicAnswers and notes", :js, type: :system do
  let(:casa_org) { create :casa_org, :all_reimbursements_enabled }
  let(:casa_case) { volunteer.casa_cases.first }
  let(:volunteer) { create :volunteer, :with_single_case, casa_org: }
  let(:user) { volunteer }

  let!(:contact_type) { create :contact_type, casa_org: }
  let(:topic_count) { 2 }
  let!(:contact_topics) { create_list :contact_topic, topic_count, casa_org: }
  let(:contact_topic_questions) { contact_topics.map(&:question) }

  let(:topic_select_class) { "contact-topic-id-select" }
  let(:topic_answer_input_class) { "contact-topic-answer-input" }

  let(:autosave_alert_div) { "#contact-form-notes" }
  let(:autosave_alert_css) { 'small[role="alert"]' }
  let(:autosave_alert_text) { "Saved!" }

  subject do
    sign_in user
    visit new_case_contact_path(casa_case)
  end

  def notes_section
    page.find_by_id("contact-form-notes")
  end

  it "has no topic inputs shown until 'Add Note' button is clicked" do
    subject

    expect(notes_section).to have_no_field(class: topic_select_class)
    expect(notes_section).to have_no_field(class: topic_answer_input_class)
    click_on "Add Note"

    expect(notes_section).to have_field(class: topic_select_class)
    expect(notes_section).to have_field(class: topic_answer_input_class)
  end

  it "lists all contact topics in the topic select" do
    subject

    click_on "Add Note"

    expect(notes_section).to have_select(class: topic_select_class, options: contact_topic_questions)
  end

  it "shows selected topic details in tooltip",
    pending: "TODO: must use stimulus controller to swap tooltip on selection" do
    subject

    click_on "Add Note"
    answer_topic contact_topics.first.question, nil
    expect(notes_section.find(".contact-topic-tooltip")).to have_content(contact_topics.first.details)

    answer_topic contact_topics.last.question, nil

    expect(notes_section.find(".contact-topic-tooltip")).to have_content(contact_topics.last.details)
  end

  it "adds contact answers for the topics" do
    subject
    fill_in_contact_details(contact_types: [contact_type.name])

    topic_one = contact_topics.first
    topic_two = contact_topics.last

    fill_in_notes(contact_topic_answers_attrs: [
      {question: topic_one.question, answer: "First discussion topic answer."},
      {question: topic_two.question, answer: "Second discussion topic answer."}
    ])

    expect { click_on "Submit" }
      .to change(CaseContact.active, :count).by(1)
      .and change(ContactTopicAnswer, :count).by(2)

    case_contact = CaseContact.active.last
    expect(case_contact.reload.contact_topic_answers).to be_present
    first_topic_answer = case_contact.contact_topic_answers.find_by(contact_topic_id: topic_one.id)
    second_topic_answer = case_contact.contact_topic_answers.find_by(contact_topic_id: topic_two.id)
    expect(first_topic_answer.value).to eq "First discussion topic answer."
    expect(second_topic_answer.value).to eq "Second discussion topic answer."
  end

  it "prevents adding more answers than topics",
    pending: "TODO: use stimulus controller to filter select options on selection" do
    subject

    contact_topics.size.times do
      click_on "Add Note"
    end

    expect(notes_section).to have_no_button "Add Note"
  end

  it "prevents adding more than one answer per topic",
    pending: "TODO: use stimulus controller to disable/enable Add Note button" do
    subject

    click_on "Add Note"

    topic_one_question = contact_topics.first.question
    answer_topic topic_one_question, "First discussion topic answer."

    click_on "Add Note"
    expect(notes_section).to have_select(class: topic_select_class, count: 2)
    expect(notes_section).to have_select(class: topic_select_class, with_options: [topic_one_question], count: 1)
  end

  context "when casa org has no contact topics" do
    let(:contact_topics) { [] }

    it "displays an 'Additional Notes' option in the topic select" do
      subject
      click_on "Add Note"

      expect(notes_section).to have_select(class: topic_select_class, options: ["Additional Notes"])
    end

    it "saves 'Additional Notes' answer as contact.notes" do
      subject
      fill_in_contact_details(contact_types: [contact_type.name])

      click_on "Add Note"
      answer_topic "Additional Notes", "This is a fake a topic answer."

      expect { click_on "Submit" }.to change(CaseContact.active, :count).by(1)

      contact = CaseContact.active.last
      expect(contact.contact_topic_answers).to be_empty
      expect(contact.notes).to eq "This is a fake a topic answer."
    end
  end

  context "when editing existing an case contact" do
    let(:case_contact) { create :case_contact, casa_case:, creator: user }

    subject do
      sign_in user
      visit edit_case_contact_path(case_contact)
    end

    context "when there are existing contact topic answers" do
      let(:topic_one) { contact_topics.first }
      let!(:answer_one) { create :contact_topic_answer, contact_topic: topic_one, case_contact: }
      let(:topic_two) { contact_topics.second }
      let!(:answer_two) { create :contact_topic_answer, contact_topic: topic_two, case_contact: }

      it "fills inputs with the answers" do
        subject

        expect(notes_section).to have_select(class: topic_select_class, count: 2)
        expect(notes_section).to have_field(class: topic_answer_input_class, count: 2)

        expect(notes_section).to have_field(class: topic_answer_input_class, with: answer_one.value)
        expect(notes_section).to have_field(class: topic_answer_input_class, with: answer_two.value)
        expect(notes_section).to have_select(
          class: topic_select_class, selected: topic_one.question, options: contact_topic_questions
        )
        expect(notes_section).to have_select(
          class: topic_select_class, selected: topic_two.question, options: contact_topic_questions
        )
      end

      it "can remove an existing answer" do
        subject
        fill_in_contact_details

        expect(notes_section).to have_select(class: topic_select_class, count: 2)

        accept_confirm do
          notes_section.find_button(text: "Delete", match: :first).click
        end

        expect { click_on "Submit" }
          .to change(ContactTopicAnswer, :count).by(-1)

        case_contact.reload
        expect(case_contact.contact_topic_answers.size).to eq(1)
        expect(case_contact.contact_topic_answers.first.value).to eq answer_two.value
      end
    end

    it "autosaves form with answer inputs" do
      expect { subject }.to change(CaseContact, :count).by(1)
      case_contact = CaseContact.last
      expect(case_contact.casa_case).to eq casa_case
      fill_in_contact_details(
        contact_made: false, medium: "In Person", occurred_on: 1.day.ago.to_date, hours: 1, minutes: 5
      )

      click_on "Add Note"
      expect {
        answer_topic contact_topics.first.question, "Topic One answer."
        within autosave_alert_div do
          find(autosave_alert_css, text: autosave_alert_text)
        end
      }
        .to change(ContactTopicAnswer, :count).by(1)
      case_contact.reload
      expect(case_contact.contact_topic_answers.size).to eq(1)
      expect(case_contact.contact_topic_answers.last.value).to eq "Topic One answer."

      expect(case_contact.contact_made).to be false
      expect(case_contact.medium_type).to eq "in-person"
      expect(case_contact.duration_minutes).to eq 65
      expect(case_contact.occurred_at).to eq 1.day.ago.to_date
    end

    context "when contact notes exist" do
      let(:notes) { "This was previously saved as 'case_contact.notes'." }

      before { case_contact.update! notes: }

      it "presents notes as an 'Additional Notes' topic answer in the select" do
        subject

        expect(notes_section).to have_select(class: topic_select_class, count: 1)
        expect(notes_section).to have_field(class: topic_answer_input_class, count: 1)

        expect(notes_section).to have_select(
          class: topic_select_class, selected: "Additional Notes", options: ["Additional Notes", *contact_topic_questions]
        )
        expect(notes_section).to have_field(class: topic_answer_input_class, with: case_contact.notes)
      end

      it "can convert notes to a topic answer" do
        subject

        new_topic = contact_topics.first
        answer_topic new_topic.question, nil # leave the notes/answer as is

        expect { click_on "Submit" }
          .to change(ContactTopicAnswer, :count).by(1)

        answer = case_contact.reload.contact_topic_answers.last
        expect(answer).to be_present
        expect(answer.contact_topic).to eq new_topic
        expect(answer.value).to eq "This was previously saved as 'case_contact.notes'."
        expect(case_contact.notes).to be_empty
      end

      it "remains as note if topic unchanged" do
        subject

        click_on "Add Note"
        answer_topic contact_topics.first.question, "Some new topic answer."

        expect { click_on "Submit" }.to change(ContactTopicAnswer, :count).by(1)

        expect(case_contact.reload.notes).to eq "This was previously saved as 'case_contact.notes'."
      end
    end
  end
end
