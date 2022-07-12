require "rails_helper"

RSpec.describe CaseContacts::FollowupsController, type: :controller do
  let(:admin) { create(:casa_admin) }
  let(:supervisor) { create(:supervisor) }
  let(:volunteer) { create(:volunteer, supervisor: supervisor) }
  let(:contact) { create(:case_contact) }

  describe "POST create" do
    context "when admin" do
      before do
        sign_in admin
      end

      context "with invalid case contact" do
        it "raises an error" do
          expect { post :create, params: {case_contact_id: 444444} }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with valid case contact" do
        context "no followup exists yet" do
          context "when a note is provided" do
            it "creates a followup" do
              expect { post :create, params: {case_contact_id: contact.id, note: "Hello, World!"} }.to change(Followup, :count).by(1)
            end

            it "contains a note" do
              post :create, params: {case_contact_id: contact.id, note: "Hello, World!"}

              expect(Followup.last.note).to eq "Hello, World!"
            end
          end

          context "when a note is not provided" do
            it "creates a followup" do
              expect { post :create, params: {case_contact_id: contact.id} }.to change(Followup, :count).by(1)
            end

            it "contains a note" do
              post :create, params: {case_contact_id: contact.id}

              expect(Followup.last.note).to eq nil
            end
          end
        end

        context "followup exists and is in :requested status" do
          it "should NOT create another followup" do
            create(:followup, case_contact: contact)

            expect { post :create, params: {case_contact_id: contact.id} }.not_to change(Followup, :count)
          end
        end
      end

      context "when no params are provided" do
        it "raises an error" do
          expect { post :create }.to raise_error(ActionController::UrlGenerationError)
        end
      end

      context "notifications" do
        let(:volunteer_2) { create(:volunteer) }
        let(:unassigned_volunteer) { create(:volunteer) }

        it "should only create a notification for the user that created the case_contact" do
          contact_created_by_volunteer = create(:case_contact, creator: volunteer)
          casa_case = contact_created_by_volunteer.casa_case
          casa_case.assigned_volunteers = [volunteer, volunteer_2]

          post :create, params: {case_contact_id: contact_created_by_volunteer.id}

          expect(volunteer.notifications.count).to eq(1)
          expect(volunteer_2.notifications.count).to eq(0)
          expect(unassigned_volunteer.notifications.count).to eq(0)
        end
      end
    end

    context "when supervisor" do
      before do
        sign_in supervisor
      end

      context "with invalid case contact" do
        it "raises an error" do
          expect { post :create, params: {case_contact_id: 444444} }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with valid case contact" do
        context "no followup exists yet" do
          context "when a note is provided" do
            it "creates a followup" do
              expect { post :create, params: {case_contact_id: contact.id, note: "Hello, World!"} }.to change(Followup, :count).by(1)
            end

            it "contains a note" do
              post :create, params: {case_contact_id: contact.id, note: "Hello, World!"}

              expect(Followup.last.note).to eq "Hello, World!"
            end
          end

          context "when a note is not provided" do
            it "creates a followup" do
              expect { post :create, params: {case_contact_id: contact.id} }.to change(Followup, :count).by(1)
            end

            it "contains a note" do
              post :create, params: {case_contact_id: contact.id}

              expect(Followup.last.note).to eq nil
            end
          end
        end

        context "followup exists and is in :requested status" do
          it "should NOT create another followup" do
            create(:followup, case_contact: contact)

            expect { post :create, params: {case_contact_id: contact.id} }.not_to change(Followup, :count)
          end
        end
      end

      context "when no params are provided" do
        it "raises an error" do
          expect { post :create }.to raise_error(ActionController::UrlGenerationError)
        end
      end

      context "notifications" do
        let(:volunteer_2) { create(:volunteer) }
        let(:unassigned_volunteer) { create(:volunteer) }

        it "should only create a notification for the user that created the case_contact" do
          contact_created_by_volunteer = create(:case_contact, creator: volunteer)
          casa_case = contact_created_by_volunteer.casa_case
          casa_case.assigned_volunteers = [volunteer, volunteer_2]

          post :create, params: {case_contact_id: contact_created_by_volunteer.id}

          expect(volunteer.notifications.count).to eq(1)
          expect(volunteer_2.notifications.count).to eq(0)
          expect(unassigned_volunteer.notifications.count).to eq(0)
        end
      end
    end

    context "when volunteer" do
      before do
        sign_in volunteer
      end

      context "with invalid case contact" do
        it "raises an error" do
          expect { post :create, params: {case_contact_id: 444444} }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "with valid case contact" do
        context "no followup exists yet" do
          context "when a note is provided" do
            it "creates a followup" do
              expect { post :create, params: {case_contact_id: contact.id, note: "Hello, World!"} }.to change(Followup, :count).by(1)
            end

            it "contains a note" do
              post :create, params: {case_contact_id: contact.id, note: "Hello, World!"}

              expect(Followup.last.note).to eq "Hello, World!"
            end
          end

          context "when a note is not provided" do
            it "creates a followup" do
              expect { post :create, params: {case_contact_id: contact.id} }.to change(Followup, :count).by(1)
            end

            it "contains a note" do
              post :create, params: {case_contact_id: contact.id}

              expect(Followup.last.note).to eq nil
            end
          end
        end

        context "followup exists and is in :requested status" do
          it "should NOT create another followup" do
            create(:followup, case_contact: contact)

            expect { post :create, params: {case_contact_id: contact.id} }.not_to change(Followup, :count)
          end
        end
      end

      context "when no params are provided" do
        it "raises an error" do
          expect { post :create }.to raise_error(ActionController::UrlGenerationError)
        end
      end
    end
  end

  describe "PATCH resolve" do
    context "when admin" do
      before do
        sign_in admin
      end

      context "followup exists" do
        it "marks it as :resolved" do
          followup = create(:followup, case_contact: contact)

          patch :resolve, params: {id: followup.id}

          expect(followup.reload.resolved?).to be_truthy
        end
      end

      context "followup doesn't exists" do
        it "raises ActiveRecord::RecordNotFound" do
          expect { post :create, params: {case_contact_id: 444444} }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "when supervisor" do
      before do
        sign_in supervisor
      end

      context "followup exists" do
        it "marks it as :resolved" do
          followup = create(:followup, case_contact: contact)

          patch :resolve, params: {id: followup.id}

          expect(followup.reload.resolved?).to be_truthy
        end
      end

      context "followup doesn't exists" do
        it "raises ActiveRecord::RecordNotFound" do
          expect { post :create, params: {case_contact_id: 444444} }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "when volunteer" do
      before do
        sign_in volunteer
      end

      context "followup exists" do
        it "marks it as :resolved" do
          followup = create(:followup, case_contact: contact)

          patch :resolve, params: {id: followup.id}

          expect(followup.reload.resolved?).to be_truthy
        end
      end

      context "followup doesn't exists" do
        it "raises ActiveRecord::RecordNotFound" do
          expect { post :create, params: {case_contact_id: 444444} }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "notifications" do
        context "volunteer is able to resolve followup when admin is creator" do
          it "should create a notification for the admin" do
            followup = create(:followup, creator: admin, case_contact: contact)

            patch :resolve, params: {id: followup.id}

            expect(Notification.count).to eq(1)
            expect(admin.notifications.count).to eq(1)
          end
        end

        context "volunteer resolves followup that they created" do
          it "should not create a notification" do
            followup = create(:followup, creator: volunteer, case_contact: contact)

            patch :resolve, params: {id: followup.id}

            expect(Notification.count).to eq(0)
          end
        end
      end
    end
  end
end
