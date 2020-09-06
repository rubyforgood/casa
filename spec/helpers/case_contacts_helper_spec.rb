require "rails_helper"

describe CaseContactsHelper do
  describe "#render_back_link" do
    it "renders back link to home page when user is a volunteer" do
      current_user = create(:volunteer)
      casa_case = create(:casa_case)
      allow(helper).to receive(:current_user).and_return(current_user)

      expect(helper.render_back_link(casa_case)).to eq(root_path)
    end

    it "renders back link to home page when user does not exist" do
      casa_case = create(:casa_case)
      allow(helper).to receive(:current_user).and_return(nil)

      expect(helper.render_back_link(casa_case)).to eq(root_path)
    end

    it "renders back link to home page when user is a supervisor" do
      current_user = create(:supervisor)
      casa_case = create(:casa_case)
      allow(helper).to receive(:current_user).and_return(current_user)

      expect(helper.render_back_link(casa_case)).to eq(casa_case_path(casa_case))
    end

    it "renders back link to home page when user is a administrator" do
      current_user = create(:casa_admin)
      casa_case = create(:casa_case)
      allow(helper).to receive(:current_user).and_return(current_user)

      expect(helper.render_back_link(casa_case)).to eq(casa_case_path(casa_case))
    end
  end

  describe "#duration_minutes" do
    it "returns remainder if duration_minutes is set" do
      case_contact = build(:case_contact, duration_minutes: 80)
      expect(helper.duration_minutes(case_contact)).to eq(20)
    end

    it "returns zero if duration_minutes is zero" do
      case_contact = build(:case_contact, duration_minutes: 0)
      expect(helper.duration_minutes(case_contact)).to eq(0)
    end

    it "returns zero if duration_minutes is nil" do
      case_contact = build(:case_contact, duration_minutes: nil)
      expect(helper.duration_minutes(case_contact)).to eq(0)
    end
  end

  describe "#duration_hours" do
    it "returns minutes if duration_minutes is set" do
      case_contact = build(:case_contact, duration_minutes: 80)
      expect(helper.duration_hours(case_contact)).to eq(1)
    end

    it "returns zero if duration_minutes is zero" do
      case_contact = build(:case_contact, duration_minutes: 0)
      expect(helper.duration_hours(case_contact)).to eq(0)
    end

    it "returns zero if duration_minutes is nil" do
      case_contact = build(:case_contact, duration_minutes: nil)
      expect(helper.duration_hours(case_contact)).to eq(0)
    end
  end
end
