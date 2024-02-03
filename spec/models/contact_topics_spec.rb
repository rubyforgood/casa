require "rails_helper"

RSpec.describe ContactTopics, type: :model do
  let(:casa_org) { build(:casa_org) }
  let(:contact_topics) { [{"test" => "test"}] }
  let(:permitted_attributes) { %w[test] }

  before do
    allow(YAML).to receive(:load_file).and_return(contact_topics)

    stub_const("ContactTopicsValidator::PERMITTED_ATTRIBUTES", permitted_attributes)
  end

  describe "sets the default topics for organization" do
    let(:casa_org) { create(:casa_org, :no_twilio) }

    it "sets the default topics for organization" do
      expect(casa_org.contact_topics).to eq([])
      ContactTopics.generate_for_org!(casa_org)
      expect(casa_org.reload.contact_topics).to eq(contact_topics)
    end
  end
end
