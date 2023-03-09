require "rails_helper"

RSpec.describe "ReimbursementDatatable" do
  let(:org) { CasaOrg.first }
  let(:case_contacts) { CaseContact.joins(:casa_case) }
  let(:instance) { described_class.new(case_contacts, params) }
  let(:json_result) { instance.as_json }
  let(:first_result) { json_result[:data].first }
  let(:order_by) { nil }
  let(:order_direction) { nil }
  let(:page) { 1 }
  let(:per_page) { 10 }
  let(:params) do
    datatable_params(
      order_by: order_by,
      order_direction: order_direction,
      page: page,
      per_page: per_page
    )
  end

  # Requires the following to be defined:
  # - `sorted_case_contacts` = array of reimbursement records ordered in the expected way
  shared_examples_for "a sorted results set" do
    it "should order ascending by default" do
      expect(first_result[:id]).to eq(sorted_case_contacts.first.id.to_s)
    end

    describe "explicit ascending order" do
      let(:order_direction) { "ASC" }

      it "should order correctly" do
        expect(first_result[:id]).to eq(sorted_case_contacts.first.id.to_s)
      end
    end

    describe "descending order" do
      let(:order_direction) { "DESC" }

      it "should order correctly" do
        expect(first_result[:id]).to eq(sorted_case_contacts.last.id.to_s)
      end
    end
  end

  describe "the data shape" do
    let(:first_contact) { case_contacts.first }

    before do
      create(:case_contact, casa_case: create(:casa_case))
    end

    describe ":casa_case" do
      subject(:casa_case) { first_result[:casa_case] }

      it { is_expected.to include(id: first_contact.casa_case.id.to_s) }
      it { is_expected.to include(case_number: first_contact.casa_case.case_number.to_s) }
    end

    describe ":volunteer" do
      subject(:volunteer) { first_result[:volunteer] }

      it { is_expected.to include(id: first_contact.creator.id.to_s) }
      it { is_expected.to include(display_name: first_contact.creator.display_name.to_s) }
      it { is_expected.to include(email: first_contact.creator.email.to_s) }
      it { is_expected.to include(address: first_contact.creator.address.to_s) }
    end

    describe ":contact_types" do
      subject(:contact_types) { first_result[:contact_types] }
      let(:expected_contact_types) do
        first_contact.contact_types.map do |ct|
          {
            name: ct.name,
            group_name: ct.contact_type_group.name
          }
        end
      end

      it { is_expected.to eq(expected_contact_types) }
    end

    describe ":occurred_at" do
      subject(:occurred_at) { first_result[:occurred_at] }

      it { is_expected.to eq(first_contact.occurred_at.to_s) }
    end

    describe ":miles_driven" do
      subject(:miles_driven) { first_result[:miles_driven] }

      it { is_expected.to eq(first_contact.miles_driven.to_s) }
    end

    describe ":complete" do
      subject(:complete) { first_result[:complete] }

      it { is_expected.to eq(first_contact.reimbursement_complete.to_s) }
    end

    describe ":mark_as_complete_path" do
      subject(:mark_as_complete_path) { first_result[:mark_as_complete_path] }

      it { is_expected.to eq("/reimbursements/#{first_contact.id}/mark_as_complete") }
    end
  end

  describe "multiple record handling" do
    before do
      5.times.collect do
        casa_case = create(:casa_case)
        3.times.collect do
          create(
            :case_contact,
            casa_case: casa_case,
            occurred_at: Time.new - rand(1000),
            miles_driven: rand(1000)
          )
        end.reverse
      end.flatten
    end

    it "should have the correct recordsFiltered" do
      expect(json_result[:recordsFiltered]).to eq(15)
    end

    it "should have the correct recordsTotal" do
      expect(json_result[:recordsTotal]).to eq(15)
    end

    it "should yield the correct number of records" do
      expect(json_result[:data].size).to eq 10
    end

    describe "order by creator display name" do
      let(:order_by) { "display_name" }
      let(:sorted_case_contacts) do
        case_contacts.sort_by { |case_contact| case_contact.creator.display_name }
      end

      it_behaves_like "a sorted results set"
    end

    describe "order by created at" do
      let(:order_by) { "occurred_at" }
      let(:sorted_case_contacts) do
        case_contacts.sort_by { |case_contact| case_contact.occurred_at }
      end

      it_behaves_like "a sorted results set"
    end

    describe "order by miles driven" do
      let(:order_by) { "miles_driven" }
      let(:sorted_case_contacts) do
        case_contacts.sort_by { |case_contact| case_contact.miles_driven }
      end

      it_behaves_like "a sorted results set"
    end

    describe "order by case number" do
      let(:order_by) { "case_number" }
      let(:sorted_case_contacts) { case_contacts.sort_by { |case_contact| case_contact.casa_case.case_number } }
      let(:first_case_number) { first_result[:casa_case][:case_number] }
      let(:lowest_case_number) { sorted_case_contacts.first.casa_case.case_number }

      it "should order ascending by default" do
        expect(first_case_number).to eq(lowest_case_number)
      end

      describe "explicit ascending order" do
        let(:order_direction) { "ASC" }

        it "should order correctly" do
          expect(first_case_number).to eq(lowest_case_number)
        end
      end

      describe "descending order" do
        let(:order_direction) { "DESC" }
        let(:highest_case_number) { sorted_case_contacts.last.casa_case.case_number }

        it "should order correctly" do
          expect(first_case_number).to eq(highest_case_number)
        end
      end
    end
  end
end
