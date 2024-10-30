require "rails_helper"

RSpec.describe ContactTopic, type: :model do
  specify do
    expect(subject).to belong_to(:casa_org)
    expect(subject).to have_many(:contact_topic_answers)

    expect(subject).to validate_presence_of(:question)
    expect(subject).to validate_presence_of(:details)

    expect(subject).to have_db_column(:details).of_type(:text).with_options(limit: nil)
  end

  describe "scopes" do
    describe ".active" do
      subject { described_class.active }

      it "returns only active and non-soft deleted contact topics" do
        active_contact_topic = create(:contact_topic, active: true, soft_delete: false)
        inactive_contact_topic = create(:contact_topic, active: false, soft_delete: false)
        soft_deleted_contact_topic = create(:contact_topic, active: true, soft_delete: true)

        expect(subject).to include(active_contact_topic)
        expect(subject).not_to include(inactive_contact_topic)
        expect(subject).not_to include(soft_deleted_contact_topic)
      end
    end
  end

  describe "#generate_for_org!" do
    subject { described_class.generate_for_org!(org) }

    let(:org) { create(:casa_org) }
    let(:fake_topics) { [{"question" => "Test Title", "details" => "Test details"}] }

    describe "generate_contact_topics" do
      before do
        allow(ContactTopic).to receive(:default_contact_topics).and_return(fake_topics)
      end

      it "creates contact topics" do
        expect { subject }.to change { org.contact_topics.count }.by(1)

        created_topic = org.contact_topics.first
        expect(created_topic.question).to eq(fake_topics.first["question"])
        expect(created_topic.details).to eq(fake_topics.first["details"])
      end

      context "there are no default topics" do
        let(:fake_topics) { [] }

        it { expect { subject }.not_to(change { org.contact_topics.count }) }
      end

      it "generates from parameter" do
        topics = fake_topics.push({"question" => "a", "details" => "a"})
        expect { subject }.to change { org.contact_topics.count }.by(2)

        questions = org.contact_topics.map(&:question)
        details = org.contact_topics.map(&:details)
        expect(questions).to match_array(topics.map { |t| t["question"] })
        expect(details).to match_array(topics.map { |t| t["details"] })
      end

      it "fails if not all required attrs are present" do
        fake_topics.first["question"] = nil

        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "creates if needed fields all present" do
        fake_topics.first["invalid_field"] = "invalid"
        expect { subject }.to change { org.contact_topics.count }.by(1)
      end
    end
  end
end
