require "rails_helper"

RSpec.describe CourtDateParams, type: :controller do
  let(:host) do
    Class.new do
      include CourtDateParams

      attr_accessor :params

      def initialize(params)
        @params = params
      end
    end
  end

  it "exists and defines private API" do
    expect(described_class).to be_a(Module)
    expect(host.private_instance_methods)
      .to include(:sanitized_court_date_params, :court_date_params)
  end

  describe "#sanitized_court_date_params" do
    let(:casa_case) { create(:casa_case) }
    let(:controller) { host.new(params) }

    context "when case_court_orders_attributes contains blank entries" do
      let(:params) do
        ActionController::Parameters.new(
          court_date: {
            date: "2025-10-15",
            case_court_orders_attributes: {
              "0" => {text: "Valid order", implementation_status: "not_implemented"},
              "1" => {text: "", implementation_status: ""},
              "2" => {text: "Another valid order", implementation_status: "partially_implemented"}
            }
          }
        )
      end

      it "removes entries where both text and implementation_status are blank" do
        result = controller.send(:sanitized_court_date_params, casa_case)
        expect(result[:case_court_orders_attributes].keys).to contain_exactly("0", "2")
      end

      it "sets casa_case_id for remaining entries" do
        result = controller.send(:sanitized_court_date_params, casa_case)
        expect(result[:case_court_orders_attributes]["0"][:casa_case_id]).to eq(casa_case.id)
        expect(result[:case_court_orders_attributes]["2"][:casa_case_id]).to eq(casa_case.id)
      end
    end

    context "when case_court_orders_attributes has text but blank implementation_status" do
      let(:params) do
        ActionController::Parameters.new(
          court_date: {
            date: "2025-10-15",
            case_court_orders_attributes: {
              "0" => {text: "Order with text only", implementation_status: ""}
            }
          }
        )
      end

      it "keeps the entry" do
        result = controller.send(:sanitized_court_date_params, casa_case)
        expect(result[:case_court_orders_attributes].keys).to include("0")
      end
    end

    context "when case_court_orders_attributes has implementation_status but blank text" do
      let(:params) do
        ActionController::Parameters.new(
          court_date: {
            date: "2025-10-15",
            case_court_orders_attributes: {
              "0" => {text: "", implementation_status: "implemented"}
            }
          }
        )
      end

      it "keeps the entry" do
        result = controller.send(:sanitized_court_date_params, casa_case)
        expect(result[:case_court_orders_attributes].keys).to include("0")
      end
    end

    context "when case_court_orders_attributes is nil" do
      let(:params) do
        ActionController::Parameters.new(
          court_date: {
            date: "2025-10-15"
          }
        )
      end

      it "does not raise an error" do
        expect { controller.send(:sanitized_court_date_params, casa_case) }.not_to raise_error
      end
    end

    context "when case_court_orders_attributes is present" do
      let(:params) do
        ActionController::Parameters.new(
          court_date: {
            date: "2025-10-15",
            case_court_orders_attributes: {
              "0" => {text: "Test order", implementation_status: "not_implemented"}
            }
          }
        )
      end

      it "returns the court_date parameter" do
        result = controller.send(:sanitized_court_date_params, casa_case)
        expect(result[:date]).to eq("2025-10-15")
      end
    end
  end

  describe "#court_date_params" do
    let(:casa_case) { create(:casa_case) }
    let(:controller) { host.new(params) }

    context "with all permitted attributes" do
      let(:hearing_type) { create(:hearing_type, casa_org: casa_case.casa_org) }
      let(:judge) { create(:judge, casa_org: casa_case.casa_org) }
      let(:params) do
        ActionController::Parameters.new(
          court_date: {
            date: "2025-10-15",
            hearing_type_id: hearing_type.id,
            judge_id: judge.id,
            court_report_due_date: "2025-10-10",
            case_court_orders_attributes: {
              "0" => {
                text: "Test order",
                implementation_status: "not_implemented",
                id: "123",
                casa_case_id: casa_case.id,
                _destroy: "false"
              }
            }
          }
        )
      end

      it "permits all allowed attributes" do
        result = controller.send(:court_date_params, casa_case)
        expect(result.permitted?).to be true
        expect(result[:date]).to eq("2025-10-15")
        expect(result[:hearing_type_id]).to eq(hearing_type.id)
        expect(result[:judge_id]).to eq(judge.id)
        expect(result[:court_report_due_date]).to eq("2025-10-10")
      end

      it "permits nested case_court_orders_attributes" do
        result = controller.send(:court_date_params, casa_case)
        order_attrs = result[:case_court_orders_attributes]["0"]
        expect(order_attrs[:text]).to eq("Test order")
        expect(order_attrs[:implementation_status]).to eq("not_implemented")
        expect(order_attrs[:id]).to eq("123")
        expect(order_attrs[:casa_case_id]).to eq(casa_case.id)
        expect(order_attrs[:_destroy]).to eq("false")
      end
    end

    context "with unpermitted attributes" do
      let(:params) do
        ActionController::Parameters.new(
          court_date: {
            date: "2025-10-15",
            unauthorized_field: "should not be permitted",
            case_court_orders_attributes: {
              "0" => {
                text: "Test order",
                implementation_status: "not_implemented",
                unauthorized_nested_field: "should not be permitted"
              }
            }
          }
        )
      end

      it "filters out unpermitted attributes" do
        result = controller.send(:court_date_params, casa_case)
        expect(result.to_h.keys).not_to include("unauthorized_field")
      end

      it "filters out unpermitted nested attributes" do
        result = controller.send(:court_date_params, casa_case)
        order_attrs = result[:case_court_orders_attributes]["0"]
        expect(order_attrs.to_h.keys).not_to include("unauthorized_nested_field")
      end
    end

    context "when sanitized_court_date_params removes blank orders" do
      let(:params) do
        ActionController::Parameters.new(
          court_date: {
            date: "2025-10-15",
            case_court_orders_attributes: {
              "0" => {text: "Valid order", implementation_status: "not_implemented"},
              "1" => {text: "", implementation_status: ""}
            }
          }
        )
      end

      it "only includes non-blank orders in the result" do
        result = controller.send(:court_date_params, casa_case)
        expect(result[:case_court_orders_attributes].keys).to eq(["0"])
      end
    end
  end
end
