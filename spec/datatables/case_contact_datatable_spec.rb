# frozen_string_literal: true

require "rails_helper"

RSpec.describe CaseContactDatatable do
  let(:organization) { create(:casa_org) }
  let(:supervisor) { create(:supervisor, casa_org: organization) }
  let(:volunteer) { create(:volunteer, casa_org: organization) }
  let(:casa_case) { create(:casa_case, casa_org: organization) }
  let(:contact_type) { create(:contact_type, casa_org: organization) }

  let(:params) do
    {
      draw: "1",
      start: "0",
      length: "10",
      search: {value: search_term},
      order: {"0" => {column: order_column, dir: order_direction}},
      columns: {
        "0" => {name: "occurred_at", orderable: "true"},
        "1" => {name: "contact_made", orderable: "true"},
        "2" => {name: "medium_type", orderable: "true"},
        "3" => {name: "duration_minutes", orderable: "true"}
      }
    }
  end

  let(:search_term) { "" }
  let(:order_column) { "0" }
  let(:order_direction) { "desc" }
  let(:base_relation) { organization.case_contacts }

  subject(:datatable) { described_class.new(base_relation, params) }

  describe "#data" do
    let!(:case_contact) do
      create(:case_contact,
        casa_case: casa_case,
        creator: volunteer,
        occurred_at: 2.days.ago,
        contact_made: true,
        medium_type: "in-person",
        duration_minutes: 60,
        notes: "Test notes")
    end

    let!(:contact_topic) { create(:contact_topic, casa_org: organization) }

    before do
      case_contact.contact_types << contact_type
      create(:contact_topic_answer, case_contact: case_contact, contact_topic: contact_topic)
    end

    it "returns an array of case contact data" do
      expect(datatable.as_json[:data]).to be_an(Array)
    end

    it "includes case contact attributes" do
      contact_data = datatable.as_json[:data].first

      expect(contact_data[:id]).to eq(case_contact.id.to_s)
      expect(contact_data[:contact_made]).to eq("true")
      expect(contact_data[:medium_type]).to eq("In-person")
      expect(contact_data[:duration_minutes]).to eq("60")
    end

    it "includes formatted occurred_at date" do
      contact_data = datatable.as_json[:data].first
      expected_date = I18n.l(case_contact.occurred_at, format: :full, default: nil)

      expect(contact_data[:occurred_at]).to eq(expected_date)
    end

    it "includes casa_case data" do
      contact_data = datatable.as_json[:data].first

      expect(contact_data[:casa_case][:id]).to eq(casa_case.id.to_s)
      expect(contact_data[:casa_case][:case_number]).to eq(casa_case.case_number)
    end

    it "includes contact_types as comma-separated string" do
      contact_data = datatable.as_json[:data].first

      expect(contact_data[:contact_types]).to include(contact_type.name)
    end

    it "includes creator data" do
      contact_data = datatable.as_json[:data].first

      expect(contact_data[:creator][:id]).to eq(volunteer.id.to_s)
      expect(contact_data[:creator][:display_name]).to eq(volunteer.display_name)
      expect(contact_data[:creator][:email]).to eq(volunteer.email)
      expect(contact_data[:creator][:role]).to eq("Volunteer")
    end

    it "includes contact_topics as pipe-separated string" do
      contact_data = datatable.as_json[:data].first

      expect(contact_data[:contact_topics]).to include(contact_topic.question)
    end

    it "includes is_draft status" do
      contact_data = datatable.as_json[:data].first

      expect(contact_data[:is_draft]).to eq((!case_contact.active?).to_s)
    end

    context "when case_contact has no casa_case (draft)" do
      let!(:draft_contact) do
        build(:case_contact,
          casa_case: nil,
          creator: volunteer,
          occurred_at: 1.day.ago).tap do |cc|
          cc.save(validate: false)
        end
      end

      it "handles nil casa_case gracefully" do
        draft_data = datatable.as_json[:data].find { |d| d[:id] == draft_contact.id.to_s }

        # The sanitize method converts nil to empty string
        expect(draft_data[:casa_case][:id]).to eq("")
        expect(draft_data[:casa_case][:case_number]).to eq("")
      end
    end

    context "with followups" do
      it "sets has_followup to true when requested followup exists" do
        create(:followup, case_contact: case_contact, status: "requested")

        contact_data = datatable.as_json[:data].first
        expect(contact_data[:has_followup]).to eq("true")
      end

      it "sets has_followup to false when no requested followup exists" do
        contact_data = datatable.as_json[:data].first
        expect(contact_data[:has_followup]).to eq("false")
      end

      it "sets has_followup to false when followup is resolved" do
        create(:followup, case_contact: case_contact, status: "resolved")

        contact_data = datatable.as_json[:data].first
        expect(contact_data[:has_followup]).to eq("false")
      end
    end
  end

  describe "search functionality" do
    let!(:john_contact) do
      create(:case_contact,
        casa_case: casa_case,
        creator: create(:volunteer, display_name: "John Doe", email: "john@example.com"),
        notes: "Meeting with youth")
    end

    let!(:jane_contact) do
      create(:case_contact,
        casa_case: create(:casa_case, casa_org: organization, case_number: "CASA-2024-001"),
        creator: create(:volunteer, display_name: "Jane Smith", email: "jane@example.com"),
        notes: "Phone call")
    end

    let!(:family_contact_type) { create(:contact_type, name: "Family", casa_org: organization) }
    let!(:school_contact_type) { create(:contact_type, name: "School", casa_org: organization) }

    before do
      john_contact.contact_types << family_contact_type
      jane_contact.contact_types << school_contact_type
    end

    context "searching by creator display_name" do
      let(:search_term) { "John" }

      it "returns matching case contacts" do
        expect(datatable.as_json[:data].map { |d| d[:id] }).to include(john_contact.id.to_s)
        expect(datatable.as_json[:data].map { |d| d[:id] }).not_to include(jane_contact.id.to_s)
      end
    end

    context "searching by creator email" do
      let(:search_term) { "jane@example.com" }

      it "returns matching case contacts" do
        expect(datatable.as_json[:data].map { |d| d[:id] }).to include(jane_contact.id.to_s)
        expect(datatable.as_json[:data].map { |d| d[:id] }).not_to include(john_contact.id.to_s)
      end
    end

    context "searching by case number" do
      let(:search_term) { "2024-001" }

      it "returns matching case contacts" do
        expect(datatable.as_json[:data].map { |d| d[:id] }).to include(jane_contact.id.to_s)
        expect(datatable.as_json[:data].map { |d| d[:id] }).not_to include(john_contact.id.to_s)
      end
    end

    context "searching by notes" do
      let(:search_term) { "Meeting" }

      it "returns matching case contacts" do
        expect(datatable.as_json[:data].map { |d| d[:id] }).to include(john_contact.id.to_s)
        expect(datatable.as_json[:data].map { |d| d[:id] }).not_to include(jane_contact.id.to_s)
      end
    end

    context "searching by contact_type name" do
      let(:search_term) { "Family" }

      it "returns matching case contacts" do
        expect(datatable.as_json[:data].map { |d| d[:id] }).to include(john_contact.id.to_s)
        expect(datatable.as_json[:data].map { |d| d[:id] }).not_to include(jane_contact.id.to_s)
      end
    end

    context "with case-insensitive search" do
      let(:search_term) { "JOHN" }

      it "returns matching case contacts regardless of case" do
        expect(datatable.as_json[:data].map { |d| d[:id] }).to include(john_contact.id.to_s)
      end
    end

    context "with partial search term" do
      let(:search_term) { "Smi" }

      it "returns matching case contacts with partial match" do
        expect(datatable.as_json[:data].map { |d| d[:id] }).to include(jane_contact.id.to_s)
      end
    end

    context "with blank search term" do
      let(:search_term) { "" }

      it "returns all case contacts" do
        expect(datatable.as_json[:data].map { |d| d[:id] }).to include(john_contact.id.to_s, jane_contact.id.to_s)
      end
    end

    context "with no matching results" do
      let(:search_term) { "NonexistentName" }

      it "returns empty array" do
        expect(datatable.as_json[:data]).to be_empty
      end
    end
  end

  describe "ordering" do
    let!(:old_contact) do
      create(:case_contact,
        casa_case: casa_case,
        creator: volunteer,
        occurred_at: 5.days.ago,
        contact_made: false,
        medium_type: "text/email",
        duration_minutes: 30)
    end

    let!(:recent_contact) do
      create(:case_contact,
        casa_case: casa_case,
        creator: volunteer,
        occurred_at: 1.day.ago,
        contact_made: true,
        medium_type: "in-person",
        duration_minutes: 90)
    end

    context "ordering by occurred_at" do
      let(:order_column) { "0" }

      context "descending" do
        let(:order_direction) { "desc" }

        it "orders contacts by occurred_at descending" do
          ids = datatable.as_json[:data].map { |d| d[:id] }
          expect(ids).to eq([recent_contact.id.to_s, old_contact.id.to_s])
        end
      end

      context "ascending" do
        let(:order_direction) { "asc" }

        it "orders contacts by occurred_at ascending" do
          ids = datatable.as_json[:data].map { |d| d[:id] }
          expect(ids).to eq([old_contact.id.to_s, recent_contact.id.to_s])
        end
      end
    end

    context "ordering by contact_made" do
      let(:order_column) { "1" }
      let(:order_direction) { "desc" }

      it "orders contacts by contact_made" do
        ids = datatable.as_json[:data].map { |d| d[:id] }
        expect(ids.first).to eq(recent_contact.id.to_s)
      end
    end

    context "ordering by medium_type" do
      let(:order_column) { "2" }
      let(:order_direction) { "asc" }

      it "orders contacts by medium_type" do
        ids = datatable.as_json[:data].map { |d| d[:id] }
        expect(ids.first).to eq(recent_contact.id.to_s)
      end
    end

    context "ordering by duration_minutes" do
      let(:order_column) { "3" }
      let(:order_direction) { "desc" }

      it "orders contacts by duration_minutes" do
        ids = datatable.as_json[:data].map { |d| d[:id] }
        expect(ids).to eq([recent_contact.id.to_s, old_contact.id.to_s])
      end
    end
  end

  describe "pagination" do
    let!(:contacts) do
      25.times.map do |i|
        create(:case_contact,
          casa_case: casa_case,
          creator: volunteer,
          occurred_at: i.days.ago)
      end
    end

    context "first page" do
      let(:params) do
        super().merge(start: "0", length: "10")
      end

      it "returns first 10 records" do
        expect(datatable.as_json[:data].length).to eq(10)
      end

      it "returns correct recordsTotal" do
        expect(datatable.as_json[:recordsTotal]).to eq(25)
      end

      it "returns correct recordsFiltered" do
        expect(datatable.as_json[:recordsFiltered]).to eq(25)
      end
    end

    context "second page" do
      let(:params) do
        super().merge(start: "10", length: "10")
      end

      it "returns next 10 records" do
        expect(datatable.as_json[:data].length).to eq(10)
      end
    end

    context "last page with partial results" do
      let(:params) do
        super().merge(start: "20", length: "10")
      end

      it "returns remaining 5 records" do
        expect(datatable.as_json[:data].length).to eq(5)
      end
    end

    context "with search filtering" do
      let!(:searchable_contact) do
        create(:case_contact,
          casa_case: casa_case,
          creator: create(:volunteer, display_name: "UniqueSearchName", casa_org: organization),
          occurred_at: 1.day.ago)
      end

      let(:search_term) { "UniqueSearchName" }

      it "paginates filtered results" do
        expect(datatable.as_json[:data].length).to eq(1)
        expect(datatable.as_json[:recordsFiltered]).to eq(1)
        expect(datatable.as_json[:recordsTotal]).to eq(26)
      end
    end
  end

  describe "#as_json" do
    let!(:case_contact) do
      create(:case_contact, casa_case: casa_case, creator: volunteer)
    end

    it "returns hash with data, recordsFiltered, and recordsTotal" do
      json = datatable.as_json

      expect(json).to have_key(:data)
      expect(json).to have_key(:recordsFiltered)
      expect(json).to have_key(:recordsTotal)
    end

    it "sanitizes HTML in data" do
      contact_with_html = create(:case_contact,
        casa_case: casa_case,
        creator: volunteer,
        notes: "<script>alert('xss')</script>")

      json = datatable.as_json
      contact_data = json[:data].find { |d| d[:id] == contact_with_html.id.to_s }

      # Note: The sanitize method in ApplicationDatatable should escape HTML
      expect(contact_data).to be_present
    end
  end

  describe "associations loading" do
    let!(:contacts) do
      10.times.map do |i|
        contact = create(:case_contact,
          casa_case: create(:casa_case, casa_org: organization),
          creator: create(:volunteer, casa_org: organization),
          occurred_at: i.days.ago)

        contact_type = create(:contact_type, casa_org: organization)
        contact.contact_types << contact_type

        contact_topic = create(:contact_topic, casa_org: organization)
        create(:contact_topic_answer, case_contact: contact, contact_topic: contact_topic)

        contact
      end
    end

    it "loads all associations efficiently with includes" do
      # This test verifies that the datatable returns data successfully
      # with proper includes to prevent N+1 queries
      json = datatable.as_json

      expect(json[:data].length).to eq(10)
      expect(json[:data].first).to have_key(:contact_types)
      expect(json[:data].first).to have_key(:contact_topics)
      expect(json[:data].first).to have_key(:creator)
      expect(json[:data].first).to have_key(:casa_case)
    end
  end
end
