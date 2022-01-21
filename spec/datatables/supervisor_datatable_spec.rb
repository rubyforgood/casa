require "rails_helper"

RSpec.describe SupervisorDatatable do
  subject { described_class.new(org.supervisors, params).as_json }

  let(:org) { create(:casa_org) }
  let(:order_by) { "display_name" }
  let(:order_direction) { "asc" }
  let(:params) { datatable_params(order_by: nil, additional_filters: additional_filters) }

  describe "filter" do
    let!(:active_supervisor) { create(:supervisor, casa_org: org, active: true) }
    let!(:inactive_supervisor) { create(:supervisor, casa_org: org, active: false) }

    describe "active" do
      context "when active" do
        let(:additional_filters) { {active: %w[true]} }

        it "brings only active supervisors", :aggregate_failures do
          expect(subject[:recordsTotal]).to eq(2)
          expect(subject[:recordsFiltered]).to eq(1)
          expect(subject[:data].map { |d| d[:display_name] }).to include(CGI.escapeHTML(active_supervisor.display_name))
          expect(subject[:data].map { |d| d[:display_name] }).not_to include(CGI.escapeHTML(inactive_supervisor.display_name))
        end
      end

      context "when inactive" do
        let(:additional_filters) { {active: %w[false]} }

        it "brings only inactive supervisors", :aggregate_failures do
          expect(subject[:recordsTotal]).to eq(2)
          expect(subject[:recordsFiltered]).to eq(1)
          expect(subject[:data].map { |d| d[:display_name] }).to include(CGI.escapeHTML(inactive_supervisor.display_name))
          expect(subject[:data].map { |d| d[:display_name] }).not_to include(CGI.escapeHTML(active_supervisor.display_name))
        end
      end

      context "when both" do
        let(:additional_filters) { {active: %w[false true]} }
        let!(:inactive_supervisor) { create(:supervisor, casa_org: org, active: true, display_name: "Neil O'Reilly") }

        it "brings only all supervisors", :aggregate_failures do
          expect(subject[:recordsTotal]).to eq(2)
          expect(subject[:recordsFiltered]).to eq(2)
          expect(subject[:data].map { |d| d[:display_name] }).to include(CGI.escapeHTML(active_supervisor.display_name))
          expect(subject[:data].map { |d| d[:display_name] }).to include(CGI.escapeHTML(inactive_supervisor.display_name))
        end
      end

      context "when no selection" do
        let(:additional_filters) { {active: []} }

        it "brings nothing", :aggregate_failures do
          expect(subject[:recordsTotal]).to eq(2)
          expect(subject[:recordsFiltered]).to eq(0)
        end
      end
    end
  end
end
