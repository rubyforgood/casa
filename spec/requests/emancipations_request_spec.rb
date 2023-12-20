require "rails_helper"

RSpec.describe "/casa_case/:id/emancipation", type: :request do
  let(:organization) { build(:casa_org) }
  let(:other_organization) { create(:casa_org) }
  let(:casa_case) { create(:casa_case, casa_org: organization, birth_month_year_youth: 15.years.ago) }
  let(:casa_admin) { create(:casa_admin, casa_org: organization) }

  describe "GET /show" do
    before { sign_in casa_admin }

    subject(:request) do
      get casa_case_emancipation_path(casa_case, :docx)

      response
    end

    it { is_expected.to be_successful }

    it "authorizes casa case" do
      expect_any_instance_of(EmancipationsController).to receive(:authorize).with(casa_case).and_call_original
      request
    end

    it "populates and sends correct emancipation template" do
      sablon_template = double("Sablon::Template")
      allow(Sablon).to(
        receive(:template).with(
          File.expand_path("app/documents/templates/emancipation_checklist_template.docx")
        ).and_return(sablon_template)
      )
      allow(Sablon).to receive(:content).and_return([])

      expect(EmancipationChecklistDownloadHtml).to receive(:new).with(casa_case, []).and_call_original

      expected_context = {case_number: casa_case.case_number, emancipation_checklist: []}
      expect(sablon_template).to(
        receive(:render_to_string).with(expected_context, type: :docx).and_return("rendered context")
      )

      expect_any_instance_of(EmancipationsController).to(
        receive(:send_data).with(
          "rendered context", filename: "#{casa_case.case_number} Emancipation Checklist.docx"
        ).and_call_original
      )
      request
    end

    context "when request is not .docx" do
      subject(:request) do
        get casa_case_emancipation_path(casa_case)

        response
      end

      it { is_expected.to be_successful }

      it "does not send any data" do
        expect_any_instance_of(EmancipationsController).not_to receive(:send_data)
        request
      end
    end
  end

  describe "POST /save" do
    before { sign_in casa_admin }

    let(:category) { create(:emancipation_category) }
    let(:option_a) { create(:emancipation_option, emancipation_category_id: category.id, name: "A") }
    let(:params) { {check_item_action: "add_option", check_item_id: option_a.id} }

    subject(:request) do
      post save_casa_case_emancipation_path(casa_case), params: params

      response
    end

    it { is_expected.to be_successful }
    it "authorizes save_emancipation?" do
      expect_any_instance_of(EmancipationsController).to(
        receive(:authorize).with(CasaCase, :save_emancipation?).and_call_original
      )
      expect_any_instance_of(EmancipationsController).to(
        receive(:authorize).with(casa_case, :update_emancipation_option?).and_call_original
      )
      request
    end

    context "when check_item_id is invalid" do
      let(:params) { {check_item_action: "add_option", check_item_id: -1} }

      it { is_expected.not_to be_successful }
      it "shows correct error message" do
        body = request.parsed_body
        expect(body).to eq({"error" => "Tried to destroy an association that does not exist"})
      end
    end

    context "when check_item_action is invalid" do
      let(:params) { {check_item_action: "invalid", check_item_id: option_a.id} }

      it { is_expected.not_to be_successful }
      it "shows correct error message" do
        body = request.parsed_body
        expect(body).to eq({"error" => "Check item action: invalid is not a supported action"})
      end
    end

    context "when casa_case is not transitioning" do
      let(:params) { {check_item_action: "add_option", check_item_id: option_a.id} }
      let(:casa_case) do
        create(:casa_case,
          casa_org: organization, emancipation_options: [], emancipation_categories: [],
          birth_month_year_youth: 13.years.ago)
      end

      it { is_expected.not_to be_successful }
      it "shows correct error message" do
        body = request.parsed_body
        expect(body).to eq({"error" => "The current case is not marked as transitioning"})
      end
    end

    describe "each check_item_action" do
      context "with the add_category action" do
        let(:params) { {check_item_action: "add_category", check_item_id: category.id} }

        it { is_expected.to be_successful }
        it "adds the category" do
          expect { request }.to change { casa_case.emancipation_categories.count }.by(1)
        end

        context "when the category is already added to the case" do
          let(:casa_case) do
            create(:casa_case, casa_org: organization, emancipation_categories: [category])
          end

          it { is_expected.not_to be_successful }

          it "does not add the category" do
            expect { request }.not_to change { casa_case.emancipation_categories.count }
          end

          it "shows correct error message" do
            body = request.parsed_body
            expect(body).to eq({"error" => "The record already exists as an association on the case"})
          end
        end
      end

      context "with the add_option action" do
        let(:params) { {check_item_action: "add_option", check_item_id: option_a.id} }

        it { is_expected.to be_successful }
        it "adds the option" do
          expect { request }.to change { casa_case.emancipation_options.count }.by(1)
        end

        context "when the option is already added to the case" do
          let(:casa_case) do
            create(:casa_case, casa_org: organization, emancipation_options: [option_a])
          end

          it { is_expected.not_to be_successful }

          it "does not add the option" do
            expect { request }.not_to change { casa_case.emancipation_options.count }
          end

          it "shows correct error message" do
            body = request.parsed_body
            expect(body).to eq({"error" => "The record already exists as an association on the case"})
          end
        end
      end

      context "with the delete_category action" do
        let(:params) { {check_item_action: "delete_category", check_item_id: category.id} }
        let(:casa_case) do
          create(:casa_case,
            casa_org: organization, emancipation_categories: [category], emancipation_options: [option_a])
        end

        it { is_expected.to be_successful }

        it "removes the category" do
          expect { request }.to change { casa_case.emancipation_categories.count }.by(-1)
        end

        it "removes all options associated with the category" do
          expect { request }.to change { casa_case.emancipation_options.count }.by(-1)
        end

        context "when the category is not added to the case" do
          let(:casa_case) { create(:casa_case, casa_org: organization, emancipation_categories: []) }

          it { is_expected.not_to be_successful }

          it "does not remove anything" do
            expect { request }.not_to change { casa_case.emancipation_categories.count }
          end

          it "shows correct error message" do
            body = request.parsed_body
            expect(body).to eq({"error" => "Tried to destroy an association that does not exist"})
          end
        end
      end

      context "with the delete_option action" do
        let(:params) { {check_item_action: "delete_option", check_item_id: option_a.id} }
        let(:casa_case) do
          create(:casa_case, casa_org: organization, emancipation_options: [option_a])
        end

        it { is_expected.to be_successful }
        it "removes the option" do
          expect { request }.to change { casa_case.emancipation_options.count }.by(-1)
        end

        context "when the option is not added to the case" do
          let(:casa_case) do
            create(:casa_case, casa_org: organization, emancipation_options: [])
          end

          it { is_expected.not_to be_successful }

          it "does not remove anything" do
            expect { request }.not_to change { casa_case.emancipation_options.count }
          end

          it "shows correct error message" do
            body = request.parsed_body
            expect(body).to eq({"error" => "Tried to destroy an association that does not exist"})
          end
        end
      end

      context "with the set_option action" do
        let(:other_category) { create(:emancipation_category) }
        let(:options) { create_list(:emancipation_option, 3, emancipation_category_id: other_category.id) }
        let(:option) { options.first }
        let(:params) { {check_item_action: "set_option", check_item_id: option.id} }

        let(:casa_case) do
          create(:casa_case, casa_org: organization, emancipation_options: [option_a, *options])
        end

        it { is_expected.to be_successful }
        it "sets the option according to the right category" do
          request
          expect(casa_case.reload.emancipation_options).to contain_exactly(option_a, option)
        end
      end
    end
  end
end
