require "rails_helper"

RSpec.describe CaseContactsHelper do
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

  describe "#show_volunteer_reimbursement" do
    before(:each) do
      @casa_cases = []
      @casa_cases << create(:casa_case)
      @casa_org = @casa_cases[0].casa_org
      @current_user = create(:volunteer, casa_org: @casa_org)
    end

    it "returns true if allow_reimbursement is true" do
      create(:case_assignment, casa_case: @casa_cases[0], volunteer: @current_user)
      allow(helper).to receive(:current_user).and_return(@current_user)
      expect(helper.show_volunteer_reimbursement(@casa_cases)).to eq(true)
    end

    it "returns false if allow_reimbursement is false" do
      create(:case_assignment, :disallow_reimbursement, casa_case: @casa_cases[0], volunteer: @current_user)
      allow(helper).to receive(:current_user).and_return(@current_user)
      expect(helper.show_volunteer_reimbursement(@casa_cases)).to eq(false)
    end

    it "returns false if no case_assigmnents are found" do
      allow(helper).to receive(:current_user).and_return(@current_user)
      expect(helper.show_volunteer_reimbursement(@casa_cases)).to eq(false)
    end
  end

  describe "#expand_filters?" do
    it "returns false if filterrific param does not exist" do
      allow(helper).to receive(:params)
        .and_return({})

      expect(helper.expand_filters?).to eq(false)
    end

    it "returns false if filterrific contains only surfaced params" do
      allow(helper).to receive(:params)
        .and_return({filterrific: {surfaced_param: "true"}})

      expect(helper.expand_filters?([:surfaced_param])).to eq(false)
    end

    it "returns true if filterrific contains any other key" do
      allow(helper).to receive(:params)
        .and_return({filterrific: {surfaced_param: "true", other_key: "value"}})

      expect(helper.expand_filters?([:surfaced_param])).to eq(true)
    end
  end
end
