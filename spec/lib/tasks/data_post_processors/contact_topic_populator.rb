require "rails_helper"
require "./lib/tasks/data_post_processors/contact_topic_populator"

RSpec.describe "populates each existing organization with contact groups and types" do
  let(:fake_topics) { [{"question" => "Test Title", "details" => "Test details"}] }
  let(:org_one) { create(:casa_org) }
  let(:org_two) { create(:casa_org) }

  before do
    Rake::Task.clear
    Casa::Application.load_tasks

    allow(ContactTopic).to receive(:default_contact_topics).and_return(fake_topics)
    ContactTopicPopulator.populate
  end

  it "does nothing on an empty database" do
    ContactTopicPopulator.populate

    expect(ContactTopic.count).to eq(0)
    expect(ContactTopicAnswer.count).to eq(0)
  end

  context "there are orgs" do
    before {
      org_one
      org_two
    }

    it "populates contact_topics" do
      expect {
        ContactTopicPopulator.populate
      }.to change(ContactTopic, :count).from(0).to(2)

      questions = ContactTopic.all.map(&:question)
      details = ContactTopic.all.map(&:details)
      active = ContactTopic.all.map(&:active)

      expect(questions).to be_all("Test Title")
      expect(details).to be_all("Test details")
      expect(active).to be_all(true)
    end

    context "there are case_contacts" do
      let(:case_one) { create(:casa_case, casa_org: org_one) }
      let(:case_two) { create(:casa_case, casa_org: org_two) }

      before {
        create_list(:case_contact, 3, casa_case: case_one)
        create_list(:case_contact, 3, casa_case: case_two)
      }

      it "populates contact_topics_answers for each case_contact" do
        ContactTopicPopulator.populate

        case_contacts = CaseContact.all
        case_contacts.each do |case_contact|
          expect(case_contact.contact_topic_answers).to_not be_empty
        end

        answers = case_contacts.map(&:contact_topic_answers).flatten
        answers.each do |answer|
          expect(answer.contact_topic).to_not be_nil
        end

        contact_topics = answers.map(&:contact_topic)
        case_questions = contact_topics.map(&:question)
        case_details = contact_topics.map(&:details)
        expect(case_questions).to be_all("Test Title")
        expect(case_details).to be_all("Test details")
      end
    end
  end
end
