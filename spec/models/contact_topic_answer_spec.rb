require "rails_helper"

RSpec.describe ContactTopicAnswer, type: :model do
  it { should belong_to(:case_contact) }
  it { should belong_to(:contact_topic) }
  it { is_expected.to have_one(:contact_creator_casa_org).through(:case_contact) }

  it "can hold more than 255 characters" do
    expect {
      create(:contact_topic_answer, value: Faker::Lorem.characters(number: 300))
    }.not_to raise_error
  end
end
