require "rails_helper"

RSpec.describe ContactTopicAnswer, type: :model do
  it { is_expected.to belong_to(:case_contact) }
  it { is_expected.to belong_to(:contact_topic).optional(true) }
  it { is_expected.to have_one(:contact_creator).through(:case_contact) }
  it { is_expected.to have_one(:contact_creator_casa_org).through(:contact_creator) }

  it "can hold more than 255 characters" do
    expect {
      create(:contact_topic_answer, value: Faker::Lorem.characters(number: 300))
    }.not_to raise_error
  end

  it "soft deletes record instead of removing it from database" do
    answer = create(:contact_topic_answer)

    answer.destroy

    expect(answer.deleted_at).not_to be_nil
    expect(ContactTopicAnswer.with_deleted).to include(answer)
    expect(ContactTopicAnswer.all).not_to include(answer)

    answer.restore

    expect(answer.deleted_at).to be_nil
    expect(ContactTopicAnswer.all).to include(answer)
  end
end
