# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateAllCasaAdminService, type: :service do
  let(:user) { build(:user) }
  let(:params) do
    ActionController::Parameters.new(
      {
        all_casa_admin: {
          email: "casa_admin23@example.com"
        }
      }
    ).permit!
  end

  describe "#build" do
    it "initializes an AllCasaAdmin with the given params and a password" do
      allow(SecureRandom).to receive(:hex).with(10).and_return("12345678910")

      admin = CreateAllCasaAdminService.new(params, user)

      all_casa_admin = admin.build

      expect(all_casa_admin).to be_instance_of(AllCasaAdmin)
      expect(all_casa_admin).not_to be_persisted
      expect(all_casa_admin).to have_attributes(
        email: params[:all_casa_admin][:email],
        password: "12345678910"
      )
    end
  end

  describe "#create!" do
    it "creates an AllCasaAdmin with the given params and sends an invite" do
      admin = CreateAllCasaAdminService.new(params, user)
      admin.build

      expect do
        admin.create!
      end.to change(AllCasaAdmin, :count).by(1)

      casa_admin = AllCasaAdmin.last
      expect(casa_admin.invited_by_id).to eq(user.id)
      expect(casa_admin.invited_by_type).to eq("User")
      expect(casa_admin).to have_attributes(
        email: params[:all_casa_admin][:email]
      )
    end

    context "when there are errors" do
      it "does not create an AllCasaAdmin and returns the errors" do
        params = ActionController::Parameters.new(
          {
            all_casa_admin: {
              email: "invalid_email_format"
            }
          }
        ).permit!

        admin = CreateAllCasaAdminService.new(params, user)
        admin.build

        expect do
          admin.create!
        end.to raise_error(ActiveRecord::RecordInvalid, /email is invalid/i)
      end
    end
  end
end
