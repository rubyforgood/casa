# frozen_string_literal: true

require "rails_helper"

RSpec.describe LearningHourTopic, type: :model do
  it { is_expected.to belong_to(:casa_org) }
  it { is_expected.to validate_presence_of(:name) }

  it "has a valid factory" do
    expect(build(:learning_hour_topic).valid?).to be true
  end

  it "has unique names for the specified organization" do
    casa_org_one = create(:casa_org)
    casa_org_two = create(:casa_org)
    create(:learning_hour_topic, casa_org: casa_org_one, name: "Ethics")
    expect { create(:learning_hour_topic, casa_org: casa_org_one, name: "Ethics") }
      .to raise_error(ActiveRecord::RecordInvalid)
    expect { create(:learning_hour_topic, casa_org: casa_org_one, name: "Ethics    ") }
      .to raise_error(ActiveRecord::RecordInvalid)
    expect { create(:learning_hour_topic, casa_org: casa_org_one, name: "ethics") }
      .to raise_error(ActiveRecord::RecordInvalid)
    expect { create(:learning_hour_topic, casa_org: casa_org_two, name: "Ethics") }
      .to_not raise_error
  end

  describe "for_organization" do
    let!(:casa_org_one) { create(:casa_org) }
    let!(:casa_org_two) { create(:casa_org) }
    let!(:record_1) { create(:learning_hour_topic, casa_org: casa_org_one) }
    let!(:record_2) { create(:learning_hour_topic, casa_org: casa_org_two) }

    it "returns only records matching the specified organization" do
      expect(described_class.for_organization(casa_org_one)).to eq([record_1])
      expect(described_class.for_organization(casa_org_two)).to eq([record_2])
    end
  end
end
