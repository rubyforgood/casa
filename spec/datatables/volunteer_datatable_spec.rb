require "rails_helper"

RSpec.describe "VolunteerDatatable" do
  let(:org) { create :casa_org }
  let(:supervisors) { create_list :supervisor, 3, casa_org: org }
  let(:assigned_volunteers) { Volunteer.joins(:supervisor) }
  let(:subject) { described_class.new(org.volunteers, params).as_json }

  let(:additional_filters) do
    {
      active: %w[false true],
      supervisor: supervisors.map(&:display_name),
      transition_aged_youth: %w[false true]
    }
  end
  let(:order_by) { "display_name" }
  let(:order_direction) { "asc" }
  let(:page) { 1 }
  let(:per_page) { 10 }
  let(:search_term) { nil }
  let(:params) do
    datatable_params(
      additional_filters: additional_filters,
      order_by: order_by,
      order_direction: order_direction,
      page: page,
      per_page: per_page,
      search_term: search_term
    )
  end

  def values(attr)
    subject[:data].map { |d| d[attr] }
  end

  before do
    supervisors.each do |supervisor|
      supervisor.update display_name: Faker::Name.unique.name
      volunteers = create_list :volunteer, 2, casa_org: org, supervisor: supervisor

      volunteers.each_with_index do |volunteer, idx|
        volunteer.update display_name: Faker::Name.unique.name, email: Faker::Internet.unique.email
        volunteer.casa_cases << create(:casa_case, casa_org: org, transition_aged_youth: false)
        volunteer.casa_cases << create(:casa_case, casa_org: org, transition_aged_youth: idx == 1)
      end
    end

    create_list :volunteer, 2, casa_org: org
  end

  describe "order by" do
    describe "display_name" do
      let(:order_by) { "display_name" }
      let(:sorted_display_names) { assigned_volunteers.pluck(:display_name).sort.map { |n| escaped n } }
      let(:name_values) { values :display_name }

      context "when ascending" do
        it "is successful" do
          sorted_display_names.each_with_index do |name, idx|
            expect(name_values[idx]).to include name
          end
        end
      end

      context "when descending" do
        let(:order_direction) { "desc" }

        it "is succesful" do
          sorted_display_names.reverse.each_with_index do |name, idx|
            expect(name_values[idx]).to include name
          end
        end
      end
    end

    describe "email" do
      let(:order_by) { "email" }
      let(:sorted_emails) { assigned_volunteers.pluck(:email).sort }

      context "when ascending" do
        it "is successful" do
          expect(values(:email)).to eq sorted_emails
        end
      end

      context "when descending" do
        let(:order_direction) { "desc" }

        it "is successful" do
          expect(values(:email)).to eq sorted_emails.reverse
        end
      end
    end

    describe "supervisor_name" do
      let(:order_by) { "supervisor_name" }
      let(:sorted_supervisor_names) { assigned_volunteers.map(&:supervisor).map { |s| escaped s.decorate.name }.sort }
      let(:name_values) { values :supervisor_name }

      context "when ascending" do
        it "is successful" do
          sorted_supervisor_names.each_with_index do |name, idx|
            expect(name_values[idx]).to include name
          end
        end
      end

      context "when descending" do
        let(:sort_direction) { "desc" }

        it "is successful" do
          sorted_supervisor_names.each_with_index do |name, idx|
            expect(name_values[idx]).to include name
          end
        end
      end
    end

    describe "active" do
      let(:order_by) { "active" }
      let(:sorted_values) { assigned_volunteers.map { |v| v.active? ? "Active" : "Inactive" }.sort }

      before do
        supervisors.each { |s| s.volunteers.first.update active: false }
      end

      context "when ascending" do
        it "is successful" do
          expect(values(:active)).to eq sorted_values.reverse
        end
      end

      context "when descending" do
        let(:order_direction) { "desc" }

        it "is successful" do
          expect(values(:active)).to eq sorted_values
        end
      end
    end

    describe "has_transition_aged_youth_cases" do
      let(:order_by) { "has_transition_aged_youth_cases" }
      let(:sorted_values) { assigned_volunteers.map { |v| v.casa_cases.where(transition_aged_youth: true).exists? ? "Yes" : "No" }.sort }
      let(:tay_values) { values :has_transition_aged_youth_cases }

      context "when ascending" do
        it "is successful" do
          sorted_values.each_with_index do |value, idx|
            expect(tay_values[idx]).to include value
          end
        end
      end

      context "when descending" do
        let(:order_direction) { "desc" }

        it "is successful" do
          sorted_values.reverse.each_with_index do |value, idx|
            expect(tay_values[idx]).to include value
          end
        end
      end
    end

    describe "most_recent_contact_occurred_at" do
      let(:order_by) { "most_recent_contact_occurred_at" }
      let(:sorted_values) do
        assigned_volunteers.map { |v| v.case_contacts.map(&:occurred_at).max }.sort.map { |oa| oa.strftime("%B %-e, %Y") }
      end
      let(:last_contact_values) { values :most_recent_contact_occurred_at }

      before do
        CasaCase.all.each_with_index { |cc, idx| cc.case_contacts << create(:case_contact, contact_made: true, creator: cc.volunteers.first, occurred_at: idx.days.ago) }
      end

      context "when ascending" do
        it "is successful" do
          sorted_values.each_with_index do |value, idx|
            expect(last_contact_values[idx]).to include value
          end
        end
      end

      context "when descending" do
        let(:order_direction) { "desc" }

        it "is successful" do
          sorted_values.reverse.each_with_index do |value, idx|
            expect(last_contact_values[idx]).to include value
          end
        end
      end
    end

    describe "contacts_made_in_past_60_days" do
      let(:order_by) { "contacts_made_in_past_60_days" }
      let(:volunteer1) { assigned_volunteers.first }
      let(:casa_case1) { volunteer1.casa_cases.first }
      let(:volunteer2) { assigned_volunteers.second }
      let(:casa_case2) { volunteer2.casa_cases.first }

      before do
        4.times do |i|
          create :case_contact, contact_made: true, casa_case: casa_case1, creator: volunteer1, occurred_at: (19 * (i + 1)).days.ago
        end

        3.times do |i|
          create :case_contact, contact_made: true, casa_case: casa_case2, creator: volunteer2, occurred_at: (29 * (i + 1)).days.ago
        end
      end

      context "when ascending" do
        it "is successful" do
          expect(values(:contacts_made_in_past_60_days)).to eq ["2", "3", "", "", "", ""]
        end
      end

      context "when descending" do
        let(:order_direction) { "desc" }

        it "is successful" do
          expect(values(:contacts_made_in_past_60_days)).to eq ["", "", "", "", "3", "2"]
        end
      end
    end
  end

  describe "search" do
    let(:volunteer) { assigned_volunteers.first }
    let(:search_term) { volunteer.display_name }

    describe "recordsTotal" do
      it "includes all volunteers" do
        expect(subject[:recordsTotal]).to eq org.volunteers.count
      end
    end

    describe "recordsFiltered" do
      it "includes filtered volunteers" do
        expect(subject[:recordsFiltered]).to eq 1
      end
    end

    describe "display_name" do
      it "is successful" do
        display_names = values :display_name
        expect(display_names.length).to eq 1
        expect(display_names.first).to include escaped volunteer.display_name
      end
    end

    describe "email" do
      let(:search_term) { volunteer.email }

      it "is successful" do
        emails = values :email
        expect(emails.length).to eq 1
        expect(emails.first).to eq volunteer.email
      end
    end

    describe "supervisor_name" do
      let(:supervisor) { volunteer.supervisor }
      let(:search_term) { supervisor.display_name }
      let(:volunteers) { supervisor.volunteers }

      it "is successful" do
        supervisor_names = values :supervisor_name
        expect(supervisor_names.length).to eq volunteers.count
        expect(supervisor_names).to all include supervisor.display_name
      end
    end

    describe "case_numbers" do
      let(:case_number) { volunteer.casa_cases.first.case_number }
      let(:search_term) { case_number }

      it "is successful" do
        case_numbers = values :case_numbers
        expect(case_numbers.length).to eq 1
        expect(case_numbers.first).to include case_number
      end
    end
  end

  describe "filter" do
    describe "supervisor" do
      context "when unassigned excluded" do
        it "is successful" do
          expect(subject[:recordsTotal]).to eq Volunteer.count
          expect(subject[:recordsFiltered]).to eq assigned_volunteers.count
        end
      end

      context "when unassigned included" do
        before { additional_filters[:supervisor] << nil }

        it "is successful" do
          expect(subject[:recordsTotal]).to eq Volunteer.count
          expect(subject[:recordsFiltered]).to eq Volunteer.count
        end
      end

      context "when no selection" do
        before { additional_filters[:supervisor] = [] }

        it "is successful" do
          expect(subject[:recordsTotal]).to eq Volunteer.count
          expect(subject[:recordsFiltered]).to be_zero
        end
      end
    end

    describe "active" do
      before { assigned_volunteers.limit(3).update_all active: "false" }

      context "when active" do
        before { additional_filters[:active] = %w[true] }

        it "is successful" do
          expect(subject[:recordsTotal]).to eq Volunteer.count
          expect(subject[:recordsFiltered]).to eq assigned_volunteers.where(active: true).count
        end
      end

      context "when inactive" do
        before { additional_filters[:active] = %w[false] }

        it "is successful" do
          expect(subject[:recordsTotal]).to eq Volunteer.count
          expect(subject[:recordsFiltered]).to eq assigned_volunteers.where(active: false).count
        end
      end

      context "when both" do
        before { additional_filters[:active] = %w[false true] }

        it "is successful" do
          expect(subject[:recordsTotal]).to eq Volunteer.count
          expect(subject[:recordsFiltered]).to eq assigned_volunteers.count
        end
      end

      context "when no selection" do
        before { additional_filters[:active] = [] }

        it "is successful" do
          expect(subject[:recordsTotal]).to eq Volunteer.count
          expect(subject[:recordsFiltered]).to be_zero
        end
      end
    end

    describe "transition_aged_youth" do
      context "when yes" do
        before { additional_filters[:transition_aged_youth] = %w[true] }

        it "is successful" do
          expect(subject[:recordsTotal]).to eq Volunteer.count
          expect(subject[:recordsFiltered]).to eq assigned_volunteers.joins(:casa_cases).where(casa_cases: {transition_aged_youth: true}).count
        end
      end

      context "when no" do
        before { additional_filters[:transition_aged_youth] = %w[false] }

        it "is successful" do
          expect(subject[:recordsTotal]).to eq Volunteer.count
          expect(subject[:recordsFiltered]).to eq assigned_volunteers.where.not(id: CaseAssignment.select(:volunteer_id).joins(:casa_case).where(casa_cases: {transition_aged_youth: true})).count
        end
      end

      context "when both" do
        before { additional_filters[:transition_aged_youth] = %w[false true] }

        it "is successful" do
          expect(subject[:recordsTotal]).to eq Volunteer.count
          expect(subject[:recordsFiltered]).to eq assigned_volunteers.count
        end
      end

      context "when no selection" do
        before { additional_filters[:transition_aged_youth] = [] }

        it "is successful" do
          expect(subject[:recordsTotal]).to eq Volunteer.count
          expect(subject[:recordsFiltered]).to be_zero
        end
      end
    end
  end

  describe "pagination" do
    let(:page) { 2 }
    let(:per_page) { 5 }

    it "is successful" do
      expect(subject[:data].length).to eq assigned_volunteers.count - 5
    end

    describe "recordsTotal" do
      it "includes all volunteers" do
        expect(subject[:recordsTotal]).to eq org.volunteers.count
      end
    end

    describe "recordsFiltered" do
      it "includes all filtered volunteers" do
        expect(subject[:recordsFiltered]).to eq assigned_volunteers.count
      end
    end
  end
end
