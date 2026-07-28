require "rails_helper"

RSpec.shared_examples "render back link" do |user_role|
  it "renders back link to home page" do
    current_user = create(user_role)
    casa_case = create(:casa_case)
    allow(helper).to receive(:current_user).and_return(current_user)

    expect(helper.render_back_link(casa_case)).to eq(casa_case_path(casa_case))
  end
end

RSpec.shared_examples "if duration_minutes is zero or nil" do
  it "returns zero if duration_minutes is zero" do
    case_contact = build(:case_contact, duration_minutes: 0)
    expect(helper.duration_minutes(case_contact)).to eq(0)
  end

  it "returns zero if duration_minutes is nil" do
    case_contact = build(:case_contact, duration_minutes: nil)
    expect(helper.duration_minutes(case_contact)).to eq(0)
  end
end

RSpec.describe CaseContactsHelper, type: :helper do
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

    it_behaves_like "render back link", :supervisor
    it_behaves_like "render back link", :casa_admin
  end

  describe "#duration_minutes" do
    it "returns remainder if duration_minutes is set" do
      case_contact = build(:case_contact, duration_minutes: 80)
      expect(helper.duration_minutes(case_contact)).to eq(20)
    end

    it_behaves_like "if duration_minutes is zero or nil"
  end

  describe "#duration_hours" do
    it "returns minutes if duration_minutes is set" do
      case_contact = build(:case_contact, duration_minutes: 80)
      expect(helper.duration_hours(case_contact)).to eq(1)
    end

    it_behaves_like "if duration_minutes is zero or nil"
  end

  describe "#show_volunteer_reimbursement" do
    before do
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

  describe "#filters_applied?" do
    # Real ActionController::Parameters, not a Hash: Parameters is not Enumerable, which is exactly
    # what a Hash-stubbed test would hide.
    def with_params(filterrific)
      allow(helper).to receive(:params).and_return(
        ActionController::Parameters.new(filterrific.nil? ? {} : {filterrific: filterrific})
      )
    end

    it "is false with no filterrific params" do
      with_params(nil)

      expect(helper.filters_applied?).to eq(false)
    end

    it "is false when every value is blank" do
      with_params({contact_medium: "", occurred_starting_at: "", contact_made: ""})

      expect(helper.filters_applied?).to eq(false)
    end

    it "is false for an unchecked Hide drafts, which always posts 0" do
      with_params({no_drafts: "0"})

      expect(helper.filters_applied?).to eq(false)
    end

    it "is true for a checked Hide drafts" do
      with_params({no_drafts: "1"})

      expect(helper.filters_applied?).to eq(true)
    end

    it "is false for an array filter holding only a blank" do
      with_params({contact_type: [""]})

      expect(helper.filters_applied?).to eq(false)
    end

    it "is true for an array filter holding a value" do
      with_params({contact_type: ["", "3"]})

      expect(helper.filters_applied?).to eq(true)
    end

    it "is false for the default sort, which the user did not choose" do
      with_params({sorted_by: CaseContact.filterrific_default_filter_params[:sorted_by]})

      expect(helper.filters_applied?).to eq(false)
    end

    it "is true for a non-default sort, since clearing would change it back" do
      with_params({sorted_by: "occurred_at_asc"})

      expect(helper.filters_applied?).to eq(true)
    end
  end

  describe "#hidden_filter_count" do
    def with_params(filterrific)
      allow(helper).to receive(:params).and_return(
        ActionController::Parameters.new(filterrific.nil? ? {} : {filterrific: filterrific})
      )
    end

    it "is zero with no filterrific params" do
      with_params(nil)

      expect(helper.hidden_filter_count).to eq(0)
    end

    it "counts one per active field" do
      with_params({contact_medium: "in-person", contact_made: "true", occurred_starting_at: ""})

      expect(helper.hidden_filter_count).to eq(2)
    end

    it "counts a multi-value field once" do
      with_params({contact_type: ["3", "4", "5"]})

      expect(helper.hidden_filter_count).to eq(1)
    end

    it "excludes the filters surfaced in the toolbar row" do
      with_params({no_drafts: "1", sorted_by: "occurred_at_asc", contact_medium: "letter"})

      expect(helper.hidden_filter_count).to eq(1)
    end
  end
end
