require "rails_helper"
require "./lib/tasks/data_post_processors/contact_topic_populator"

RSpec.describe "populates each existing organization with contact groups and types" do
  let(:fake_topics) { [1, 2, 3].map { |i| {"question" => "Question #{i}", "details" => "Details #{i}"} } }
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
    before do
      org_one
      org_two
    end

    it "creates 3 topics per each of two orgs totalling 6" do
      expect do
        ContactTopicPopulator.populate
      end.to change(ContactTopic, :count).from(0).to(6)
    end

    context "there are case_contacts" do
      let(:case_one) { create(:casa_case, casa_org: org_one) }
      let(:case_two) { create(:casa_case, casa_org: org_two) }

      before do
        create_list(:case_contact, 3, casa_case: case_one)
        create_list(:case_contact, 3, casa_case: case_two)
      end

      it "it creates 3 topic answers for each case contact" do
        expect { ContactTopicPopulator.populate }.to change(ContactTopicAnswer, :count).from(0).to(18)
        expect(case_one.case_contacts.map(&:contact_topic_answers).flatten.size).to eq(9)
        expect(case_two.case_contacts.map(&:contact_topic_answers).flatten.size).to eq(9)

        CaseContact.all.each do |case_contact|
          expect(case_contact.contact_topic_answers.size).to eq(3)
        end
      end
    end
  end
end
