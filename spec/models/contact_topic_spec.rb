require "rails_helper"

RSpec.describe ContactTopic, type: :model do
  it { is_expected.to belong_to(:casa_org) }
  it { is_expected.to have_many(:contact_topic_answers) }

  it { is_expected.to validate_presence_of(:question) }
  it { is_expected.to validate_presence_of(:details) }

  describe "scopes" do
    describe ".active" do
      it "returns only active and non-soft deleted contact topics" do
        active_contact_topic = create(:contact_topic, active: true, soft_delete: false)
        inactive_contact_topic = create(:contact_topic, active: false, soft_delete: false)
        soft_deleted_contact_topic = create(:contact_topic, active: true, soft_delete: true)

        expect(ContactTopic.active).to include(active_contact_topic)
        expect(ContactTopic.active).not_to include(inactive_contact_topic)
        expect(ContactTopic.active).not_to include(soft_deleted_contact_topic)
      end
    end
  end

  describe "generate for org" do
    let(:org) { create(:casa_org) }
    let(:fake_topics) { [{"question" => "Test Title", "details" => "Test details"}] }

    describe "generate_contact_topics" do
      before do
        allow(ContactTopic).to receive(:default_contact_topics).and_return(fake_topics)
      end

      it "creates contact topics" do
        expect { ContactTopic.generate_for_org!(org) }.to change { org.contact_topics.count }.by(1)

        created_topic = org.contact_topics.first
        expect(created_topic.question).to eq(fake_topics.first["question"])
        expect(created_topic.details).to eq(fake_topics.first["details"])
      end

      context "there are no default topics" do
        let(:fake_topics) { [] }

        it { expect { ContactTopic.generate_for_org!(org) }.not_to(change { org.contact_topics.count }) }
      end

      it "generates from parameter" do
        topics = fake_topics.push({"question" => "a", "details" => "a"})
        expect { ContactTopic.generate_for_org!(org) }.to change { org.contact_topics.count }.by(2)

        questions = org.contact_topics.map(&:question)
        details = org.contact_topics.map(&:details)
        expect(questions).to match_array(topics.map { |t| t["question"] })
        expect(details).to match_array(topics.map { |t| t["details"] })
      end

      it "fails if not all required attrs are present" do
        fake_topics.first["question"] = nil

        expect { ContactTopic.generate_for_org!(org) }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "creates if needed fields all present" do
        fake_topics.first["invalid_field"] = "invalid"
        expect { ContactTopic.generate_for_org!(org) }.to change { org.contact_topics.count }.by(1)
      end
    end
  end

  describe "details" do
    it "can hold more than 255 characters" do
      contact_topic_details = build(:contact_topic, details: Faker::Lorem.characters(number: 300))
      expect { contact_topic_details.save! }.not_to raise_error
    end
  end
end
