require "rails_helper"

RSpec.describe "/casa_case/:id/emancipation", type: :request do
  let(:organization) { create(:casa_org) }
  let(:organization_different) { create(:casa_org) }
  let(:casa_case) { create(:casa_case, casa_org: organization, transition_aged_youth: true) }

  describe "GET /show" do
    before { sign_in user }

    context "when members and the associated casa case belong to the same org" do
      context "as an admin" do
        let(:user) { create(:casa_admin, casa_org: organization) }
        it "renders a successful response" do
          get casa_case_emancipation_path(casa_case)
          expect(response).to be_successful
        end
      end

      context "as a supervisor" do
        let(:user) { create(:supervisor, casa_org: organization) }
        it "renders a successful response" do
          get casa_case_emancipation_path(casa_case)
          expect(response).to be_successful
        end
      end

      context "as a volunteer assigned to the associated case" do
        let(:user) { create(:volunteer, casa_org: organization) }
        let!(:case_assignment) { create(:case_assignment, volunteer: user, casa_case: casa_case) }
        it "renders a successful response" do
          get casa_case_emancipation_path(casa_case)
          expect(response).to be_successful
        end
      end

      context "as a volunteer not assigned to the associated case" do
        let(:user) { create(:volunteer, casa_org: organization) }
        it "renders an unauthorized error" do
          get casa_case_emancipation_path(casa_case)
          expect(response).to_not be_successful
          expect(flash[:error]).to match(/you are not authorized/)
        end
      end
    end

    context "when members and the associated casa case belong to different orgs" do
      context "as an admin" do
        let(:user) { create(:casa_admin, casa_org: organization_different) }
        it "renders an unauthorized error" do
          get casa_case_emancipation_path(casa_case)
          expect(response).to_not be_successful
          expect(flash[:error]).to match(/you are not authorized/)
        end
      end

      context "as a supervisor" do
        let(:user) { create(:supervisor, casa_org: organization_different) }
        it "renders an unauthorized error" do
          get casa_case_emancipation_path(casa_case)
          expect(response).to_not be_successful
          expect(flash[:error]).to match(/you are not authorized/)
        end
      end

      context "as a volunteer" do
        let(:user) { create(:volunteer, casa_org: organization_different) }
        it "renders an unauthorized error" do
          get casa_case_emancipation_path(casa_case)
          expect(response).to_not be_successful
          expect(flash[:error]).to match(/you are not authorized/)
        end
      end
    end
  end

  describe "POST /save" do
    before { sign_in user }

    let(:category) { create(:emancipation_category) }
    let(:option_a) { create(:emancipation_option, emancipation_category_id: category.id, name: "A") }

    context "when accessing the route" do
      context "when members and the associated casa case belong to the same org" do
        context "as an admin" do
          let(:user) { create(:casa_admin, casa_org: organization) }
          it "allows the admin to make changes" do
            post casa_case_emancipation_path(casa_case) + "/save", params: {option_action: "add", option_id: option_a.id}
            expect(response.header["Content-Type"]).to match(/application\/json/)
            expect(JSON.parse(response.body)).to eq "success"
          end
        end

        context "as a supervisor" do
          let(:user) { create(:supervisor, casa_org: organization) }
          it "allows the supervisor to make changes" do
            post casa_case_emancipation_path(casa_case) + "/save", params: {option_action: "add", option_id: option_a.id}
            expect(response.header["Content-Type"]).to match(/application\/json/)
            expect(JSON.parse(response.body)).to eq "success"
          end
        end

        context "as a volunteer assigned to the associated case" do
          let(:user) { create(:volunteer, casa_org: organization) }
          let!(:case_assignment) { create(:case_assignment, volunteer: user, casa_case: casa_case) }
          it "allows the volunteer to make changes" do
            post casa_case_emancipation_path(casa_case) + "/save", params: {option_action: "add", option_id: option_a.id}
            expect(response.header["Content-Type"]).to match(/application\/json/)
            expect(JSON.parse(response.body)).to eq "success"
          end
        end

        context "as a volunteer not assigned to the associated case" do
          let(:user) { create(:volunteer, casa_org: organization) }
          it "sends an unauthorized error" do
            post casa_case_emancipation_path(casa_case) + "/save", params: {option_action: "add", option_id: option_a.id}
            expect(response.header["Content-Type"]).to match(/application\/json/)
            expect(response.body).to_not be_nil
            expect(JSON.parse(response.body)).to have_key("error")
            expect(JSON.parse(response.body)["error"]).to match(/you are not authorized/)
          end
        end
      end

      context "when members and the associated casa case belong to different orgs" do
        context "as an admin" do
          let(:user) { create(:casa_admin, casa_org: organization_different) }
          it "sends an unauthorized error" do
            post casa_case_emancipation_path(casa_case) + "/save", params: {option_action: "add", option_id: option_a.id}
            expect(response.header["Content-Type"]).to match(/application\/json/)
            expect(response.body).to_not be_nil
            expect(JSON.parse(response.body)).to have_key("error")
            expect(JSON.parse(response.body)["error"]).to match(/you are not authorized/)
          end
        end

        context "as a supervisor" do
          let(:user) { create(:supervisor, casa_org: organization_different) }
          it "sends an unauthorized error" do
            post casa_case_emancipation_path(casa_case) + "/save", params: {option_action: "add", option_id: option_a.id}
            expect(response.header["Content-Type"]).to match(/application\/json/)
            expect(response.body).to_not be_nil
            expect(JSON.parse(response.body)).to have_key("error")
            expect(JSON.parse(response.body)["error"]).to match(/you are not authorized/)
          end
        end

        context "as a volunteer" do
          let(:user) { create(:volunteer, casa_org: organization_different) }
          it "sends an unauthorized error" do
            post casa_case_emancipation_path(casa_case) + "/save", params: {option_action: "add", option_id: option_a.id}
            expect(response.header["Content-Type"]).to match(/application\/json/)
            expect(response.body).to_not be_nil
            expect(JSON.parse(response.body)).to have_key("error")
            expect(JSON.parse(response.body)["error"]).to match(/you are not authorized/)
          end
        end
      end
    end

    context "when passing parameters" do
      let(:mutually_exclusive_category) { create(:emancipation_category, mutually_exclusive: true, name: "mutex_category") }
      let(:mutex_option_a) { create(:emancipation_option, emancipation_category_id: mutually_exclusive_category.id, name: "A") }
      let(:mutex_option_b) { create(:emancipation_option, emancipation_category_id: mutually_exclusive_category.id, name: "B") }

      let(:user) { create(:volunteer, casa_org: organization) }
      let(:non_transitioning_casa_case) { create(:casa_case, casa_org: organization, transition_aged_youth: false) }
      let!(:case_assignment) { create(:case_assignment, volunteer: user, casa_case: casa_case) }
      let!(:case_assignment_non_transitioning_case) { create(:case_assignment, volunteer: user, casa_case: non_transitioning_casa_case) }

      it "sends an error when a required parameter is missing" do
        post casa_case_emancipation_path(casa_case) + "/save", params: {option_id: option_a.id}
        expect(JSON.parse(response.body)).to have_key("error")
        expect(JSON.parse(response.body)["error"]).to match(/Missing param/)

        post casa_case_emancipation_path(casa_case) + "/save", params: {option_action: "add"}
        expect(JSON.parse(response.body)).to have_key("error")
        expect(JSON.parse(response.body)["error"]).to match(/Missing param/)
      end

      it "sends an error when attempting to perform an action on a case that is not tranitioning" do
        post casa_case_emancipation_path(non_transitioning_casa_case) + "/save", params: {option_action: "add", option_id: option_a.id}
        expect(JSON.parse(response.body)).to have_key("error")
        expect(JSON.parse(response.body)["error"]).to match(/not marked as transitioning/)
      end

      it "associates an emancipation option with a case when passed \"add\" and the option id" do
        expect {
          post casa_case_emancipation_path(casa_case) + "/save", params: {option_action: "add", option_id: option_a.id}
        }.to change { casa_case.emancipation_options.count }.from(0).to(1)

        expect(response.header["Content-Type"]).to match(/application\/json/)
        expect(JSON.parse(response.body)).to eq "success"
      end

      it "removes an emancipation option from a case when passed \"delete\" and the option id" do
        casa_case.emancipation_options << option_a

        expect {
          post casa_case_emancipation_path(casa_case) + "/save", params: {option_action: "delete", option_id: option_a.id}
        }.to change { casa_case.emancipation_options.count }.from(1).to(0)

        expect(response.header["Content-Type"]).to match(/application\/json/)
        expect(JSON.parse(response.body)).to eq "success"
      end

      it "removes all emancipation options from the case belonging to the same category before adding the new option when passed \"set\" and the option id" do
        casa_case.emancipation_options << mutex_option_a

        post casa_case_emancipation_path(casa_case) + "/save", params: {option_action: "set", option_id: mutex_option_b.id}

        expect(response.header["Content-Type"]).to match(/application\/json/)
        expect(JSON.parse(response.body)).to eq "success"

        expect(casa_case.emancipation_options.count).to eq 1
        expect(casa_case.emancipation_options).to include(mutex_option_b)
      end

      it "does not remove emancipation options from the case belonging to different categories when passed \"set\" and the option id" do
        casa_case.emancipation_options << mutex_option_a
        casa_case.emancipation_options << option_a

        post casa_case_emancipation_path(casa_case) + "/save", params: {option_action: "set", option_id: mutex_option_b.id}

        expect(response.header["Content-Type"]).to match(/application\/json/)
        expect(JSON.parse(response.body)).to eq "success"

        expect(casa_case.emancipation_options.count).to eq 2
        expect(casa_case.emancipation_options).to include(mutex_option_b)
        expect(casa_case.emancipation_options).to include(option_a)
      end
    end
  end
end
