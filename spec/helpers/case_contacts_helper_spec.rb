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

    # Sort is not a filter. A non-default sort must not put a control labelled "Clear filters" on
    # screen, and clearing must leave the ordering alone.
    it "is false for any sort, default or not" do
      with_params({sorted_by: CaseContact.filterrific_default_filter_params[:sorted_by]})
      expect(helper.filters_applied?).to eq(false)

      with_params({sorted_by: "occurred_at_asc"})
      expect(helper.filters_applied?).to eq(false)
    end
  end

  describe "#applied_filter_chips" do
    def with_params(filterrific)
      allow(helper).to receive(:params).and_return(
        ActionController::Parameters.new(filterrific.nil? ? {} : {filterrific: filterrific})
      )
    end

    it "is empty with nothing filtering" do
      with_params({contact_medium: "", sorted_by: "occurred_at_asc"})

      expect(helper.applied_filter_chips).to be_empty
    end

    it "names each applied filter and reads its value for a human" do
      with_params({contact_medium: "in-person", contact_made: "false", no_drafts: "1"})

      expect(helper.applied_filter_chips.map { |chip| [chip[:label], chip[:value]] })
        .to contain_exactly(
          ["Contact medium", "In person"],
          ["Contact made", "No"],
          ["Hide drafts", nil] # the label already says it
        )
    end

    it "lists the selected contact types by name" do
      group = create(:contact_type_group)
      youth = create(:contact_type, contact_type_group: group, name: "Youth")
      school = create(:contact_type, contact_type_group: group, name: "School")
      with_params({contact_type: [youth.id.to_s, school.id.to_s]})

      chip = helper.applied_filter_chips.sole

      expect(chip[:label]).to eq("Contact types")
      expect(chip[:value]).to eq("School and Youth")
    end

    it "gives each chip a path that drops only that filter and keeps the sort" do
      with_params({contact_medium: "in-person", contact_made: "true", sorted_by: "occurred_at_asc"})

      medium = helper.applied_filter_chips.find { |chip| chip[:label] == "Contact medium" }

      expect(medium[:remove_path]).to include("contact_made")
      expect(medium[:remove_path]).not_to include("contact_medium")
      expect(medium[:remove_path]).to include("occurred_at_asc")
    end
  end

  describe "#clear_filters_path" do
    def with_params(filterrific)
      allow(helper).to receive(:params).and_return(
        ActionController::Parameters.new(filterrific.nil? ? {} : {filterrific: filterrific})
      )
    end

    it "drops every filter but keeps the sort" do
      with_params({contact_medium: "in-person", no_drafts: "1", sorted_by: "occurred_at_asc"})

      path = helper.clear_filters_path

      expect(path).to include("occurred_at_asc")
      expect(path).not_to include("contact_medium")
      expect(path).not_to include("no_drafts")
    end

    # Filterrific restores its session-persisted filters when the submitted hash is blank, so the
    # link has to carry something or clearing would hand the old filters straight back.
    it "always sends a filterrific hash" do
      with_params(nil)

      expect(helper.clear_filters_path).to include("filterrific")
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
