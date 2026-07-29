require "rails_helper"

RSpec.describe CaseContactDecorator do
  let(:case_contact) { build(:case_contact) }

  describe "#duration_minutes" do
    context "when duration_minutes is less than 60" do
      let(:case_contact) { build(:case_contact, duration_minutes: 30) }

      it "returns only minutes" do
        expect(case_contact.decorate.duration_minutes).to eq "30 minutes"
      end
    end

    context "when duration_minutes is greater than 60" do
      let(:case_contact) { build(:case_contact, duration_minutes: 135) }

      it "returns minutes and hours" do
        case_contact.update_attribute(:duration_minutes, 135)

        expect(case_contact.decorate.duration_minutes).to eq "2 hours 15 minutes"
      end

      context "when is exactly on hour" do
        let(:case_contact) { build(:case_contact, duration_minutes: 120) }

        it "returns only hours" do
          expect(case_contact.decorate.duration_minutes).to eq "2 hours"
        end
      end
    end

    context "when minutes is nil" do
      let(:case_contact) { build(:case_contact, duration_minutes: nil) }

      it "returns not set" do
        expect(case_contact.decorate.duration_minutes).to eq "Duration not set"
      end
    end
  end

  describe "#contact_made" do
    context "when contact_made is false" do
      it "returns No Contact Made" do
        case_contact.update_attribute(:contact_made, false)

        expect(case_contact.decorate.contact_made).to eq "No Contact Made"
      end
    end

    context "when contact_made is true" do
      it "returns Yes" do
        case_contact.update_attribute(:contact_made, true)

        expect(case_contact.decorate.contact_made).to be_nil
      end
    end
  end

  describe "#contact_types" do
    subject(:contact_types) { decorated_case_contact.contact_types }

    let(:case_contact) { build(:case_contact, contact_types: contact_types) }
    let(:decorated_case_contact) do
      described_class.new(case_contact)
    end

    context "when the contact_types is an empty array" do
      let(:contact_types) { [] }

      it { is_expected.to eql("No contact type specified") }
    end

    context "when the contact_types is an array with three or more values" do
      let(:contact_types) do
        [
          build_stubbed(:contact_type, name: "School"),
          build_stubbed(:contact_type, name: "Therapist"),
          build_stubbed(:contact_type, name: "Bio Parent")
        ]
      end

      it { is_expected.to eql("School, Therapist, and Bio Parent") }
    end

    context "when the contact types is an array with less than three values" do
      let(:contact_types) do
        [
          build_stubbed(:contact_type, name: "School"),
          build_stubbed(:contact_type, name: "Therapist")
        ]
      end

      it { is_expected.to eql("School and Therapist") }
    end
  end

  describe "#medium_icon_classes" do
    context "when medium type is in-person" do
      it "returns the proper font-awesome classes" do
        case_contact.update_attribute(:medium_type, "in-person")

        expect(case_contact.decorate.medium_icon_classes).to eql("lni lni-users")
      end
    end

    context "when medium type is text/email" do
      it "returns the proper font-awesome classes" do
        case_contact.update_attribute(:medium_type, "text/email")

        expect(case_contact.decorate.medium_icon_classes).to eql("lni lni-envelope")
      end
    end

    context "when medium type is video" do
      it "returns the proper font-awesome classes" do
        case_contact.update_attribute(:medium_type, "video")

        expect(case_contact.decorate.medium_icon_classes).to eql("lni lni-camera")
      end
    end

    context "when medium type is voice-only" do
      it "returns the proper font-awesome classes" do
        case_contact.update_attribute(:medium_type, "voice-only")

        expect(case_contact.decorate.medium_icon_classes).to eql("lni lni-phone")
      end
    end

    context "when medium type is letter" do
      it "returns the proper font-awesome classes" do
        case_contact.update_attribute(:medium_type, "letter")

        expect(case_contact.decorate.medium_icon_classes).to eql("lni lni-empty-file")
      end
    end

    context "when medium type is anything else" do
      it "returns the proper font-awesome classes" do
        case_contact.update_attribute(:medium_type, "foo")

        expect(case_contact.decorate.medium_icon_classes).to eql("lni lni-question-circle")
      end
    end
  end

  describe "#medium_icon" do
    {
      "in-person" => "bi bi-people",
      "text/email" => "bi bi-envelope",
      "video" => "bi bi-camera-video",
      "voice-only" => "bi bi-telephone",
      "letter" => "bi bi-envelope-paper",
      "something-else" => "bi bi-question-circle"
    }.each do |medium, icon|
      it "maps #{medium} to the bootstrap-icons class #{icon}" do
        case_contact.medium_type = medium

        expect(case_contact.decorate.medium_icon).to eq(icon)
      end
    end
  end

  describe "#medium_label" do
    {
      "in-person" => "In person",
      "text/email" => "Text/email",
      "video" => "Video",
      "voice-only" => "Voice only",
      "letter" => "Letter"
    }.each do |medium, label|
      it "maps #{medium} to the sentence-case label #{label}" do
        case_contact.medium_type = medium

        expect(case_contact.decorate.medium_label).to eq(label)
      end
    end

    it "falls back when the medium is not set" do
      case_contact.medium_type = nil

      expect(case_contact.decorate.medium_label).to eq("Medium not set")
    end
  end

  describe "#subheading" do
    let(:contact_group) { build_stubbed(:contact_type_group, name: "Group X") }
    let(:contact_type) { build_stubbed(:contact_type, contact_type_group: contact_group, name: "Type X") }

    context "when all information is available" do
      it "returns a properly formatted string" do
        case_contact.update(occurred_at: "2020-12-01", medium_type: "in-person", duration_minutes: 99, contact_made: false, miles_driven: 100, want_driving_reimbursement: true)
        case_contact.contact_types = [contact_type]

        expect(case_contact.decorate.subheading).to eq(
          "December 1, 2020 | In person | 1 hour 39 minutes | No Contact Made | 100 miles driven"
        )
      end
    end

    context "when some information is missing" do
      it "omits missing facts (medium, contact made) without extra pipes" do
        case_contact.update(occurred_at: "2020-12-01", duration_minutes: 99, contact_made: true, miles_driven: 100, want_driving_reimbursement: true)
        case_contact.contact_types = [contact_type]
        case_contact.medium_type = nil

        expect(case_contact.decorate.subheading).to eq(
          "December 1, 2020 | 1 hour 39 minutes | 100 miles driven"
        )
      end
    end
  end

  describe "#reimbursement_status_text" do
    context "when the reimbursement has not been completed" do
      let(:case_contact) { build(:case_contact, reimbursement_complete: false) }

      it "returns pending text" do
        expect(case_contact.decorate.reimbursement_status_text).to eq("Reimbursement Pending")
      end
    end

    context "when the reimbursement has been completed" do
      let(:case_contact) { build(:case_contact, reimbursement_complete: true) }

      it "returns complete text" do
        expect(case_contact.decorate.reimbursement_status_text).to eq("Reimbursement Complete")
      end
    end
  end

  describe "#reimbursement_status_badge_type" do
    context "when the reimbursement has not been completed" do
      let(:case_contact) { build(:case_contact, reimbursement_complete: false) }

      it "returns the warning badge type" do
        expect(case_contact.decorate.reimbursement_status_badge_type).to eq(:warning)
      end
    end

    context "when the reimbursement has been completed" do
      let(:case_contact) { build(:case_contact, reimbursement_complete: true) }

      it "returns the success badge type" do
        expect(case_contact.decorate.reimbursement_status_badge_type).to eq(:success)
      end
    end
  end
end
