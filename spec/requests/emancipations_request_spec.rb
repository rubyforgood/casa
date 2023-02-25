require "rails_helper"

RSpec.describe "/casa_case/:id/emancipation", type: :request do
  let(:organization) { build(:casa_org) }
  let(:organization_different) { create(:casa_org) }
  let(:casa_case) { create(:casa_case, casa_org: organization, birth_month_year_youth: 15.years.ago) }

  describe "GET /show" do
    before { sign_in user }

    context "when accessing the route" do
      context "as an admin" do
        let(:user) { create(:casa_admin, casa_org: organization) }

        context "when the user and case belong to the same org" do
          it "renders a successful response" do
            get casa_case_emancipation_path(casa_case)
            expect(response).to be_successful
          end

          it "renders a successful response for docx format" do
            get casa_case_emancipation_path(casa_case, format: :docx)
            expect(response).to be_successful
          end
        end

        context "when the user and case belong to different orgs" do
          it "renders an unauthorized error" do
            user.casa_org = organization_different

            get casa_case_emancipation_path(casa_case)
            expect(response).to_not be_successful
            expect(flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
          end
        end
      end

      context "as a supervisor" do
        let(:user) { create(:supervisor, casa_org: organization) }

        context "when the user and case belong to the same org" do
          it "renders a successful response" do
            get casa_case_emancipation_path(casa_case)
            expect(response).to be_successful
          end
        end

        context "when the user and case belong to defferent orgs" do
          it "renders an unauthorized error" do
            user.casa_org = organization_different

            get casa_case_emancipation_path(casa_case)
            expect(response).to_not be_successful
            expect(flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
          end
        end
      end

      context "as a volunteer" do
        let(:user) { create(:volunteer, casa_org: organization) }

        context "when not assigned to the associated case" do
          it "renders an unauthorized error" do
            get casa_case_emancipation_path(casa_case)
            expect(response).to_not be_successful
            expect(flash[:notice]).to eq "Sorry, you are not authorized to perform this action."
          end
        end

        context "when assigned to the associated case" do
          let!(:case_assignment) { create(:case_assignment, volunteer: user, casa_case: casa_case) }

          context "when the user and case belong to different orgs" do
            it "renders an unauthorized error" do
              user.casa_org = organization_different

              get casa_case_emancipation_path(casa_case)
              expect(response).to be_redirect
              expect(flash[:notice]).to eq("Sorry, you are not authorized to perform this action.")
            end
          end

          context "when the user and case belong the same org" do
            it "renders a successful response" do
              get casa_case_emancipation_path(casa_case)
              expect(response).to be_successful
            end
          end
        end
      end
    end
  end

  describe "POST /save" do
    before { sign_in user }

    let(:category) { create(:emancipation_category) }
    let(:option_a) { create(:emancipation_option, emancipation_category_id: category.id, name: "A") }

    context "when accessing the route" do
      context "as an admin" do
        let(:user) { create(:casa_admin, casa_org: organization) }

        context "when the user and case belong to the same org" do
          it "allows the admin to make changes" do
            post casa_case_emancipation_path(casa_case) + "/save", params: {check_item_action: "add_option", check_item_id: option_a.id}
            expect(response.header["Content-Type"]).to match(/application\/json/)
            expect(JSON.parse(response.body)).to eq "success"
          end
        end

        context "when the user and case belong to different orgs" do
          it "sends an unauthorized error" do
            user.casa_org = organization_different

            post casa_case_emancipation_path(casa_case) + "/save", params: {check_item_action: "add_option", check_item_id: option_a.id}
            expect(response.header["Content-Type"]).to match(/application\/json/)
            expect(response.body).to_not be_nil
            expect(JSON.parse(response.body)).to have_key("error")
            expect(JSON.parse(response.body)["error"]).to match(/you are not authorized/)
          end
        end
      end

      context "as a supervisor" do
        let(:user) { create(:supervisor, casa_org: organization) }

        context "when the user and case belong to the same org" do
          it "allows the supervisor to make changes" do
            post casa_case_emancipation_path(casa_case) + "/save", params: {check_item_action: "add_option", check_item_id: option_a.id}
            expect(response.header["Content-Type"]).to match(/application\/json/)
            expect(JSON.parse(response.body)).to eq "success"
          end
        end

        context "when the user and case belong to different orgs" do
          it "sends an unauthorized error" do
            user.casa_org = organization_different

            post casa_case_emancipation_path(casa_case) + "/save", params: {check_item_action: "add_option", check_item_id: option_a.id}
            expect(response.header["Content-Type"]).to match(/application\/json/)
            expect(response.body).to_not be_nil
            expect(JSON.parse(response.body)).to have_key("error")
            expect(JSON.parse(response.body)["error"]).to match(/you are not authorized/)
          end
        end
      end

      context "as a volunteer" do
        let(:user) { create(:volunteer, casa_org: organization) }

        context "as a volunteer not assigned to the associated case" do
          it "sends an unauthorized error" do
            post casa_case_emancipation_path(casa_case) + "/save", params: {check_item_action: "add_option", check_item_id: option_a.id}
            expect(response.header["Content-Type"]).to match(/application\/json/)
            expect(response.body).to_not be_nil
            expect(JSON.parse(response.body)).to have_key("error")
            expect(JSON.parse(response.body)["error"]).to match(/you are not authorized/)
          end
        end

        context "as a volunteer assigned to the associated case" do
          let!(:case_assignment) { create(:case_assignment, volunteer: user, casa_case: casa_case) }

          context "when the user and case belong to the same org" do
            it "allows the volunteer to make changes" do
              post casa_case_emancipation_path(casa_case) + "/save", params: {check_item_action: "add_option", check_item_id: option_a.id}
              expect(response.header["Content-Type"]).to match(/application\/json/)
              expect(JSON.parse(response.body)).to eq "success"
            end
          end

          context "when the user and case belong to different orgs" do
            it "sends an unauthorized error" do
              user.casa_org = organization_different

              post casa_case_emancipation_path(casa_case) + "/save", params: {check_item_action: "add_option", check_item_id: option_a.id}
              expect(response.header["Content-Type"]).to match(/application\/json/)
              expect(response.body).to_not be_nil
              expect(JSON.parse(response.body)).to have_key("error")
              expect(JSON.parse(response.body)["error"]).to match(/you are not authorized/)
            end
          end
        end
      end
    end

    context "when passing parameters" do
      let(:mutually_exclusive_category) { create(:emancipation_category, mutually_exclusive: true, name: "mutex_category") }
      let(:mutex_option_a) { build(:emancipation_option, emancipation_category_id: mutually_exclusive_category.id, name: "A") }
      let(:mutex_option_b) { create(:emancipation_option, emancipation_category_id: mutually_exclusive_category.id, name: "B") }

      let(:user) { create(:volunteer, casa_org: organization) }
      let(:non_transitioning_casa_case) { build(:casa_case, casa_org: organization, birth_month_year_youth: 8.years.ago) }
      let!(:case_assignment) { create(:case_assignment, volunteer: user, casa_case: casa_case) }
      let!(:case_assignment_non_transitioning_case) { create(:case_assignment, volunteer: user, casa_case: non_transitioning_casa_case) }

      it "sends an error when a required parameter is missing" do
        post casa_case_emancipation_path(casa_case) + "/save", params: {check_item_id: option_a.id}
        expect(JSON.parse(response.body)).to have_key("error")
        expect(JSON.parse(response.body)["error"]).to eq("Check item action:  is not a supported action")

        post casa_case_emancipation_path(casa_case) + "/save", params: {check_item_action: "add_option"}
        expect(JSON.parse(response.body)).to have_key("error")
        expect(JSON.parse(response.body)["error"]).to eq("Tried to destroy an association that does not exist")
      end

      it "sends an error when attempting to perform an action on a case that is not transitioning" do
        post casa_case_emancipation_path(non_transitioning_casa_case) + "/save", params: {check_item_action: "add_option", check_item_id: option_a.id}
        expect(JSON.parse(response.body)).to have_key("error")
        expect(JSON.parse(response.body)["error"]).to match(/not marked as transitioning/)
      end

      it "associates an emancipation category with a case when passed \"add_category\" and the category id" do
        expect {
          post casa_case_emancipation_path(casa_case) + "/save", params: {check_item_action: "add_category", check_item_id: mutually_exclusive_category.id}
        }.to change { casa_case.emancipation_categories.count }.from(0).to(1)

        expect(response.header["Content-Type"]).to match(/application\/json/)
        expect(JSON.parse(response.body)).to eq "success"
      end

      it "associates an emancipation option with a case when passed \"add_option\" and the option id" do
        expect {
          post casa_case_emancipation_path(casa_case) + "/save", params: {check_item_action: "add_option", check_item_id: option_a.id}
        }.to change { casa_case.emancipation_options.count }.from(0).to(1)

        expect(response.header["Content-Type"]).to match(/application\/json/)
        expect(JSON.parse(response.body)).to eq "success"
      end

      it "removes an emancipation category from a case when passed \"delete_category\" and the category id" do
        casa_case.emancipation_categories << mutually_exclusive_category

        expect {
          post casa_case_emancipation_path(casa_case) + "/save", params: {check_item_action: "delete_category", check_item_id: mutually_exclusive_category.id}
        }.to change { casa_case.emancipation_categories.count }.from(1).to(0)

        expect(response.header["Content-Type"]).to match(/application\/json/)
        expect(JSON.parse(response.body)).to eq "success"
      end

      it "removes all emancipation category options from a case when passed \"delete_category\" and the category id" do
        casa_case.emancipation_categories << mutually_exclusive_category
        casa_case.emancipation_options << mutex_option_a
        casa_case.emancipation_options << mutex_option_b

        expect {
          post casa_case_emancipation_path(casa_case) + "/save", params: {check_item_action: "delete_category", check_item_id: mutually_exclusive_category.id}
        }.to change { casa_case.emancipation_options.count }.from(2).to(0)

        expect(response.header["Content-Type"]).to match(/application\/json/)
        expect(JSON.parse(response.body)).to eq "success"
      end

      it "removes an emancipation option from a case when passed \"delete_option\" and the option id" do
        casa_case.emancipation_options << option_a

        expect {
          post casa_case_emancipation_path(casa_case) + "/save", params: {check_item_action: "delete_option", check_item_id: option_a.id}
        }.to change { casa_case.emancipation_options.count }.from(1).to(0)

        expect(response.header["Content-Type"]).to match(/application\/json/)
        expect(JSON.parse(response.body)).to eq "success"
      end

      it "removes all emancipation options from the case belonging to the same category before adding the new option when passed \"set_option\" and the option id" do
        casa_case.emancipation_options << mutex_option_a

        post casa_case_emancipation_path(casa_case) + "/save", params: {check_item_action: "set_option", check_item_id: mutex_option_b.id}

        expect(response.header["Content-Type"]).to match(/application\/json/)
        expect(JSON.parse(response.body)).to eq "success"

        expect(casa_case.emancipation_options.count).to eq 1
        expect(casa_case.emancipation_options).to include(mutex_option_b)
      end

      it "does not remove emancipation options from the case belonging to different categories when passed \"set_option\" and the option id" do
        casa_case.emancipation_options << mutex_option_a
        casa_case.emancipation_options << option_a

        post casa_case_emancipation_path(casa_case) + "/save", params: {check_item_action: "set_option", check_item_id: mutex_option_b.id}

        expect(response.header["Content-Type"]).to match(/application\/json/)
        expect(JSON.parse(response.body)).to eq "success"

        expect(casa_case.emancipation_options.count).to eq 2
        expect(casa_case.emancipation_options).to include(mutex_option_b)
        expect(casa_case.emancipation_options).to include(option_a)
      end
    end
  end
end
