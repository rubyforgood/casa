require "rails_helper"

RSpec.describe OtherDutyDecorator do
  let(:other_duty) { build(:other_duty) }

  describe "#duration_minutes" do
    context "when duration_minutes is less than 60" do
      it "returns only minutes" do
        other_duty.update_attribute(:duration_minutes, 45)

        expect(other_duty.decorate.duration_in_minutes).to eq "45 minutes"
      end
    end

    context "when duration_minutes is greater than 60" do
      it "returns minutes and hours" do
        other_duty.update_attribute(:duration_minutes, 182)

        expect(other_duty.decorate.duration_in_minutes).to eq "3 hours 2 minutes"
      end
    end
  end

  describe "#truncate_notes" do
    let(:truncated_od) {
      build(:other_duty,
        notes: "I have no fear, for fear is the little death that kills me over and over. Without fear, I die but once.")
    }

    context "when notes length is shorter than limit" do
      it "returns notes completely" do
        other_duty.update_attribute(:notes, "Short note.")

        expect(other_duty.decorate.truncate_notes).to eq("<p>Short note.</p>")
      end
    end

    context "when notes length is bigger than limit" do
      it "returns a truncated string" do
        expect(truncated_od.decorate.truncate_notes).to eq(
          "<p>I have no fear, for fear is the little death...</p>"
        )
      end
    end
  end
end
