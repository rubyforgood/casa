require "rails_helper"

RSpec.describe CaseContactParameters do
  subject { described_class.new(params) }

  let(:params) {
    ActionController::Parameters.new(
      case_contact: ActionController::Parameters.new(
        duration_hours: "1",
        duration_minutes: "2",
        occurred_at: "occurred_at",
        contact_made: "contact_made",
        medium_type: "medium_type",
        miles_driven: "123",
        want_driving_reimbursement: "want_driving_reimbursement",
        notes: "notes",
        contact_type_ids: [],
        contact_topic_answers_attributes:
      )
    )
  }
  let(:contact_topic_answers_attributes) do
    {"0" => {"id" => 1, "value" => "test",
             "question" => "question", "selected" => true}}
  end

  it "returns data" do
    expect(subject["duration_minutes"]).to eq(62)
    expect(subject["occurred_at"]).to eq("occurred_at")
    expect(subject["contact_made"]).to eq("contact_made")
    expect(subject["medium_type"]).to eq("medium_type")
    expect(subject["miles_driven"]).to eq(123)
    expect(subject["want_driving_reimbursement"]).to eq("want_driving_reimbursement")
    expect(subject["notes"]).to eq("notes")
    expect(subject["contact_type_ids"]).to eq([])

    expected_attrs = contact_topic_answers_attributes["0"].except("question")
    expect(subject["contact_topic_answers_attributes"]["0"].to_h).to eq(expected_attrs)
  end
end
