require "rails_helper"

RSpec.describe VolunteerDatatable do
  let(:org) { CasaOrg.first }
  let(:supervisors) { Supervisor.all }
  let(:assigned_volunteers) { Volunteer.joins(:supervisor) }
  let(:subject) { described_class.new(org.volunteers, params).as_json }
  let(:additional_filters) do
    {
      active: %w[false true],
      supervisor: supervisors.pluck(:id),
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

  describe ":has_transition_aged_youth_cases" do
    let(:volunteer_has_transition_aged_youth) { subject[:data].first[:has_transition_aged_youth_cases] }
    let(:non_transitional_birth) { 10.years.ago }
    let(:transitional_birth) { 16.years.ago }
    let(:org) { build :casa_org }
    let(:active_assignment) { true }

    context "with a volunteer with a case assignment" do
      let(:casa_case) { build :casa_case, casa_org: org, birth_month_year_youth: youth_month_year }
      let(:supervisor) { create :supervisor, casa_org: org }
      let(:volunteer) { create :volunteer, casa_org: org, supervisor: supervisor }
      before do
        create :case_assignment, volunteer: volunteer, casa_case: casa_case, active: active_assignment
      end

      context "which has a non-transition aged case" do
        let(:youth_month_year) { non_transitional_birth }

        it "should be 'false'" do
          expect(volunteer_has_transition_aged_youth).to eq "false"
        end
      end

      context "which had (but no longer has) a transition aged case" do
        let(:youth_month_year) { transitional_birth }
        let(:active_assignment) { false }

        it "should be 'false'" do
          expect(volunteer_has_transition_aged_youth).to eq "false"
        end
      end

      context "which has a transition aged case" do
        let(:youth_month_year) { transitional_birth }

        it "should be 'true'" do
          expect(volunteer_has_transition_aged_youth).to eq "true"
        end
      end
    end
  end

  context "with supervisors who have volunteers who have cases" do
    before :all do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start

      org = build(:casa_org)
      supervisors = create_list :supervisor, 3, casa_org: org

      supervisors.each do |supervisor|
        volunteers = create_list :volunteer, 2, casa_org: org, supervisor: supervisor

        volunteers.each_with_index do |volunteer, idx|
          volunteer.casa_cases << build(:casa_case, casa_org: org, birth_month_year_youth: (idx == 1) ? 10.years.ago : 16.years.ago)
        end
      end

      create_list :volunteer, 2, casa_org: org
    end

    after :all do
      DatabaseCleaner.clean
    end

    describe "order by" do
      let(:values) { subject[:data] }

      let(:check_attr_equality) do
        lambda { |model, idx|
          expect(values[idx][:id]).to eq model.id.to_s
        }
      end

      let(:check_asc_order) do
        lambda {
          sorted_models.each_with_index(&check_attr_equality)
        }
      end

      let(:check_desc_order) do
        lambda {
          sorted_models.reverse.each_with_index(&check_attr_equality)
        }
      end

      describe "display_name" do
        let(:order_by) { "display_name" }
        let(:sorted_models) { assigned_volunteers.order :display_name }

        context "when ascending" do
          it "is successful" do
            check_asc_order.call
          end
        end

        context "when descending" do
          let(:order_direction) { "desc" }

          it "is succesful" do
            check_desc_order.call
          end
        end
      end

      describe "email" do
        let(:order_by) { "email" }
        let(:sorted_models) { assigned_volunteers.order :email }

        context "when ascending" do
          it "is successful" do
            check_asc_order.call
          end
        end

        context "when descending" do
          let(:order_direction) { "desc" }

          it "is successful" do
            check_desc_order.call
          end
        end
      end

      describe "supervisor_name" do
        let(:order_by) { "supervisor_name" }
        let(:sorted_models) { assigned_volunteers.sort_by { |v| v.supervisor.display_name } }

        context "when ascending" do
          it "is successful" do
            sorted_models.each_with_index do |model, idx|
              expect(CGI.unescapeHTML(values[idx][:supervisor][:name])).to eq model.supervisor.display_name
            end
          end
        end

        context "when descending" do
          let(:order_direction) { "desc" }
          let(:sorted_models) { assigned_volunteers.sort_by { |v| v.supervisor.display_name } }

          it "is successful" do
            sorted_models.reverse.each_with_index do |model, idx|
              expect(CGI.unescapeHTML(values[idx][:supervisor][:name])).to eq model.supervisor.display_name
            end
          end
        end
      end

      describe "active" do
        let(:order_by) { "active" }
        let(:sorted_models) { assigned_volunteers.order :active, :id }

        before do
          supervisors.each { |s| s.volunteers.first.update active: false }
        end

        context "when ascending" do
          it "is successful" do
            check_asc_order.call
          end
        end

        context "when descending" do
          let(:order_direction) { "desc" }
          let(:sorted_models) { assigned_volunteers.order :active, id: :desc }

          it "is successful" do
            check_desc_order.call
          end
        end
      end

      describe "has_transition_aged_youth_cases" do
        let(:order_by) { "has_transition_aged_youth_cases" }
        let(:transition_aged_youth_bool_to_int) do
          lambda { |volunteer|
            volunteer.casa_cases.exists?(birth_month_year_youth: ..CasaCase::TRANSITION_AGE.years.ago) ? 1 : 0
          }
        end
        let(:sorted_models) { assigned_volunteers.sort_by(&transition_aged_youth_bool_to_int) }

        context "when ascending" do
          it "is successful" do
            sorted_models.each_with_index do |model, idx|
              expect(values[idx][:has_transition_aged_youth_cases]).to eq model.casa_cases.exists?(birth_month_year_youth: ..CasaCase::TRANSITION_AGE.years.ago).to_s
            end
          end
        end

        context "when descending" do
          let(:order_direction) { "desc" }
          let(:sorted_models) { assigned_volunteers.sort_by(&transition_aged_youth_bool_to_int) }

          it "is successful" do
            sorted_models.reverse.each_with_index do |model, idx|
              expect(values[idx][:has_transition_aged_youth_cases]).to eq model.casa_cases.exists?(birth_month_year_youth: ..CasaCase::TRANSITION_AGE.years.ago).to_s
            end
          end
        end
      end

      describe "most_recent_attempt_occurred_at" do
        let(:order_by) { "most_recent_attempt_occurred_at" }
        let(:sorted_models) do
          assigned_volunteers.order(:id).sort_by { |v| v.case_contacts.maximum :occurred_at }
        end

        before do
          CasaCase.all.each_with_index { |cc, idx| cc.case_contacts << build(:case_contact, contact_made: true, creator: cc.volunteers.first, occurred_at: idx.days.ago) }
        end

        context "when ascending" do
          it "is successful" do
            check_asc_order.call
          end
        end

        context "when descending" do
          let(:order_direction) { "desc" }

          it "is successful" do
            check_desc_order.call
          end
        end
      end

      describe "contacts_made_in_past_days" do
        let(:order_by) { "contacts_made_in_past_days" }
        let(:volunteer1) { assigned_volunteers.first }
        let(:casa_case1) { volunteer1.casa_cases.first }
        let(:volunteer2) { assigned_volunteers.second }
        let(:casa_case2) { volunteer2.casa_cases.first }
        let(:sorted_models) do
          assigned_volunteers
            .order(:id)
            .sort_by { |v| v.case_contacts.where(occurred_at: 60.days.ago.to_date..).count }
            .sort_by { |v| v.case_contacts.exists?(occurred_at: 60.days.ago.to_date..) ? 0 : 1 }
        end

        before do
          4.times do |i|
            create(:case_contact, contact_made: true, casa_case: casa_case1, creator: volunteer1, occurred_at: (19 * (i + 1)).days.ago)
          end

          3.times do |i|
            create(:case_contact, contact_made: true, casa_case: casa_case2, creator: volunteer2, occurred_at: (29 * (i + 1)).days.ago)
          end
        end

        context "when ascending" do
          it "is successful" do
            expect(values.map { |h| h[:contacts_made_in_past_days] }).to eq ["2", "3", "", "", "", ""]
          end
        end

        context "when descending" do
          let(:order_direction) { "desc" }
          let(:sorted_models) do
            assigned_volunteers
              .order(id: :desc)
              .sort_by { |v| v.case_contacts.where(occurred_at: 60.days.ago.to_date..).count }
          end

          it "is successful" do
            expect(values.map { |h| h[:contacts_made_in_past_days] }).to eq ["3", "2", "", "", "", ""]
          end

          it "should move blanks to the end" do
            expect(values[0][:contacts_made_in_past_days]).not_to be_blank
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
          expect(subject[:data].length).to eq 1
          expect(subject[:data].first[:id]).to eq volunteer.id.to_s
        end
      end

      describe "email" do
        let(:search_term) { volunteer.email }

        it "is successful" do
          expect(subject[:data].length).to eq 1
          expect(subject[:data].first[:id]).to eq volunteer.id.to_s
        end
      end

      describe "supervisor_name" do
        let(:supervisor) { volunteer.supervisor }
        let(:search_term) { supervisor.display_name }
        let(:volunteers) { supervisor.volunteers }

        it "is successful" do
          expect(subject[:data].length).to eq volunteers.count
          expect(subject[:data].map { |d| d[:id] }.sort).to eq volunteers.map { |v| v.id.to_s }.sort
        end
      end

      describe "case_numbers" do
        let(:casa_case) { volunteer.casa_cases.first }
        let(:search_term) { casa_case.case_number }

        # Sometimes the default case number is a substring of other case numbers
        before { casa_case.update case_number: Random.hex }

        it "is successful" do
          expect(subject[:data].length).to eq 1
          expect(subject[:data].first[:id]).to eq volunteer.id.to_s
        end

        context "when search term case number matches unassigned case" do
          let(:new_supervisor) { create(:supervisor, casa_org: casa_case.casa_org) }
          let(:new_casa_case) { create(:casa_case, :pre_transition, casa_org: casa_case.casa_org, case_number: "ABC-123") }
          let(:volunteer_1) { create(:volunteer, display_name: "Volunteer 1", casa_org: casa_case.casa_org, supervisor: new_supervisor) }
          let(:volunteer_2) { create(:volunteer, display_name: "Volunteer 2", casa_org: casa_case.casa_org, supervisor: new_supervisor) }
          let(:search_term) { new_casa_case.case_number }

          before do
            create(:case_assignment, casa_case: new_casa_case, volunteer: volunteer_1)
            create(:case_assignment, casa_case: new_casa_case, volunteer: volunteer_2, active: false)
          end

          it "does not include unassigned case matches in search results" do
            expect(subject[:data].length).to eq 1
            expect(subject[:data].first[:id]).to eq volunteer_1.id.to_s
          end
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
            expect(subject[:recordsTotal]).to eq 8
            expect(subject[:recordsFiltered]).to eq 3
          end
        end

        context "when no" do
          before { additional_filters[:transition_aged_youth] = %w[false] }

          it "is successful" do
            expect(subject[:recordsTotal]).to eq 8
            expect(subject[:recordsFiltered]).to eq 3
          end
        end

        context "when both" do
          before { additional_filters[:transition_aged_youth] = %w[false true] }

          it "is successful" do
            expect(subject[:recordsTotal]).to eq 8
            expect(subject[:recordsFiltered]).to eq 6
          end
        end

        context "when no selection" do
          before { additional_filters[:transition_aged_youth] = [] }

          it "is successful" do
            expect(subject[:recordsTotal]).to eq 8
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
end
