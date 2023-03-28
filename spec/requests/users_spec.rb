require "rails_helper"

RSpec.describe "/users", type: :request do
  before {
    sms_notification_event = SmsNotificationEvent.new(name: "test", user_type: Volunteer)
    sms_notification_event.save
  }

  describe "GET /edit" do
    context "with a volunteer signed in" do
      it "renders a successful response" do
        sign_in create(:volunteer)

        get edit_users_path

        expect(response).to be_successful
      end
    end

    context "with an admin signed in" do
      it "renders a successful response" do
        sign_in build(:casa_admin)

        get edit_users_path

        expect(response).to be_successful
      end
    end
  end

  describe "PATCH /update" do
    it "updates the user" do
      volunteer = build(:volunteer)
      sign_in volunteer

      patch users_path, params: {user: {display_name: "New Name", address_attributes: {content: "some address"}, phone_number: "+12223334444", sms_notification_event_ids: [SmsNotificationEvent.first.id]}}

      expect(volunteer.address.content).to eq "some address"
      expect(volunteer.display_name).to eq "New Name"
      expect(volunteer.phone_number).to eq "+12223334444"
      expect(volunteer.sms_notification_event_ids).to include SmsNotificationEvent.first.id
      expect(UserSmsNotificationEvent.count).to eq 1
    end
  end

  describe "PATCH /update_password" do
    subject do
      patch update_password_users_path(user),
        params: {
          user: {
            current_password: "12345678",
            password: "new_pass",
            password_confirmation: "new_pass"
          }
        }
    end

    before { sign_in user }

    context "when volunteer" do
      let(:user) { create(:volunteer) }

      context "when successfully" do
        it "updates the user password" do
          subject

          expect(user.valid_password?("new_pass")).to be_truthy
        end

        it "calls UserMailer to reminder the user that password has changed" do
          mailer = double(UserMailer, deliver: nil)
          allow(UserMailer).to receive(:password_changed_reminder).with(user).and_return(mailer)
          expect(mailer).to receive(:deliver)

          subject
        end
      end

      context "when failure" do
        subject do
          patch update_password_users_path(user),
            params: {
              user: {
                password: "",
                password_confirmation: "wrong"
              }
            }
        end

        it "does not update the user password", :aggregate_failures do
          subject

          expect(user.valid_password?("wrong")).to be_falsey
          expect(user.valid_password?("")).to be_falsey
        end

        it "does not call UserMailer to reminder the user that password has changed" do
          mailer = double(UserMailer, deliver: nil)
          allow(UserMailer).to receive(:password_changed_reminder).with(user).and_return(mailer)
          expect(mailer).not_to receive(:deliver)

          subject
        end
      end
    end
######################
  describe "PATCH /update_email" do
    subject do
      patch update_email_users_path(user),
        params: {
          user: {
            current_password: "12345678",
            email: "newemail@example.com",
            email_confirmation: "newemail@example.com"
          }
        }
    end

    before { sign_in user }

    context "when volunteer" do
      let(:user) { create(:volunteer) }

      context "when successfully" do
        it "updates the user email" do
          subject

          expect(user.valid_password?("12345678")).to be_truthy
        end

        it "send an alert and a confirmation email" do
          subject 
          
          expect(ActionMailer::Base.deliveries.count).to eq(2)
          expect(ActionMailer::Base.deliveries.first.body.encoded)
        .to include("We're contacting you to notify you that your email is being changed to newemail@example.com.")
          expect(ActionMailer::Base.deliveries.last.body.encoded)
        .to match("You can confirm your account email through the link below:")
        
        end
      end

      context "when failure" do
        subject do
          patch update_email_users_path(user),
            params: {
              user: {
                current_password: "wrongpassword",
                email: "wrong",
                email_confirmation: "wrong"
              }
            }
        end

        it "does not update the user password", :aggregate_failures do
          subject

          expect(user.valid_password?("wrongpassword")).to be_falsey
          expect(user.valid_password?("")).to be_falsey
        end

        it "does not call UserMailer to reminder the user that password has changed" do
         expect(ActionMailer::Base.deliveries.count).to eq(0)

          subject
        end
      end
    end 
  end 
    #######################

    context "when supervisor" do
      let(:user) { create(:supervisor) }

      context "when successfully" do
        it "updates the user password" do
          subject

          expect(user.valid_password?("new_pass")).to be_truthy
        end

        it "calls UserMailer to reminder the user that password has changed" do
          mailer = double(UserMailer, deliver: nil)
          allow(UserMailer).to receive(:password_changed_reminder).with(user).and_return(mailer)
          expect(mailer).to receive(:deliver)

          subject
        end

        it "bypasses sign in if the current user is the true user" do
          expect_any_instance_of(UsersController).to receive(:bypass_sign_in).with(user)
          subject
        end

        it "does not bypass sign in when the current user is not the true user" do
          allow_any_instance_of(UsersController).to receive(:true_user).and_return(User.new)
          expect_any_instance_of(UsersController).to_not receive(:bypass_sign_in).with(user)
          subject
        end
      end

      context "when failure" do
        subject do
          patch update_password_users_path(user),
            params: {
              user: {
                password: "",
                password_confirmation: "wrong"
              }
            }
        end

        it "does not update the user password", :aggregate_failures do
          subject

          expect(user.valid_password?("wrong")).to be_falsey
          expect(user.valid_password?("")).to be_falsey
        end

        it "does not call UserMailer to reminder the user that password has changed" do
          mailer = double(UserMailer, deliver: nil)
          allow(UserMailer).to receive(:password_changed_reminder).with(user).and_return(mailer)
          expect(mailer).not_to receive(:deliver)

          subject
        end
      end
    end

    context "when casa_admin" do
      let(:user) { create(:casa_admin) }

      context "when successfully" do
        it "updates the user password" do
          subject

          expect(user.valid_password?("new_pass")).to be_truthy
        end

        it "calls UserMailer to reminder the user that password has changed" do
          mailer = double(UserMailer, deliver: nil)
          allow(UserMailer).to receive(:password_changed_reminder).with(user).and_return(mailer)
          expect(mailer).to receive(:deliver)

          subject
        end

        it "bypasses sign in if the current user is the true user" do
          expect_any_instance_of(UsersController).to receive(:bypass_sign_in).with(user)
          subject
        end

        it "does not bypass sign in when the current user is not the true user" do
          allow_any_instance_of(UsersController).to receive(:true_user).and_return(User.new)
          expect_any_instance_of(UsersController).to_not receive(:bypass_sign_in).with(user)
          subject
        end
      end

      context "when failure" do
        subject do
          patch update_password_users_path(user),
            params: {
              user: {
                password: "",
                password_confirmation: "wrong"
              }
            }
        end

        it "does not update the user password", :aggregate_failures do
          subject

          expect(user.valid_password?("wrong")).to be_falsey
          expect(user.valid_password?("")).to be_falsey
        end

        it "does not call UserMailer to reminder the user that password has changed" do
          mailer = double(UserMailer, deliver: nil)
          allow(UserMailer).to receive(:password_changed_reminder).with(user).and_return(mailer)
          expect(mailer).not_to receive(:deliver)

          subject
        end
      end
    end
  end
  describe "PATCH /add_language" do
    let(:volunteer) { create(:volunteer) }
    before { sign_in volunteer }

    context "when request params are valid" do
      let(:language) { create(:language) }
      before(:each) do
        patch add_language_users_path(volunteer), params: {
          language_id: language.id
        }
      end

      it "should add language to current user" do
        expect(volunteer.languages).to include(language)
      end

      it "should notify the user that the language has been added" do
        expect(response).to redirect_to(edit_users_path)
        expect(flash[:notice]).to eq "#{language.name} was added to your languages list."
      end
    end

    context "when request params are invalid" do
      it "should display an error message when the Language id is empty" do
        patch add_language_users_path(volunteer), params: {
          language_id: ""
        }
        expect(response).to have_http_status(200)
        expect(response.body).to include("Please select a language before adding.")
      end
    end
  end
end
