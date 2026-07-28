# frozen_string_literal: true

require "rails_helper"

RSpec.describe CreateCasaAdminService, type: :service do
  let(:organization) { create(:casa_org) }
  let(:user) { build(:user) }
  let(:params) do
    ActionController::Parameters.new(
      {
        casa_admin: {
          email: "casa_admin23@example.com",
          display_name: "Bob Cat",
          phone_number: "+16306149615",
          date_of_birth: Date.new(1990, 1, 1),
          receive_reimbursement_email: "1",
          monthly_learning_hours_report: "1"
        }
      }
    ).permit!
  end

  describe "#build" do
    it "initializes a CasaAdmin with the given params" do
      admin = CreateCasaAdminService.new(organization, params, user)

      casa_admin = admin.build

      expect(casa_admin).to be_instance_of(CasaAdmin)
      expect(casa_admin).not_to be_persisted
      expect(casa_admin).to have_attributes(
        display_name: params[:casa_admin][:display_name],
        phone_number: params[:casa_admin][:phone_number],
        email: params[:casa_admin][:email],
        date_of_birth: params[:casa_admin][:date_of_birth],
        receive_reimbursement_email: true,
        monthly_learning_hours_report: true
      )
    end

    it "initializes a CasaAdmin with custom fields" do
      admin = CreateCasaAdminService.new(organization, params, user)

      casa_admin = admin.build

      expect(casa_admin).to have_attributes(
        active: true,
        casa_org_id: organization.id,
        type: "CasaAdmin"
      )
      expect(casa_admin.password).to be_present
    end
  end

  describe "#create!" do
    it "creates a CasaAdmin with the given params" do
      admin = CreateCasaAdminService.new(organization, params, user)
      admin.build

      expect do
        admin.create!
      end.to change(CasaAdmin, :count).by(1)

      casa_admin = CasaAdmin.last
      expect(casa_admin).to have_attributes(
        display_name: params[:casa_admin][:display_name],
        phone_number: params[:casa_admin][:phone_number],
        email: params[:casa_admin][:email],
        date_of_birth: params[:casa_admin][:date_of_birth],
        receive_reimbursement_email: true,
        monthly_learning_hours_report: true,
        active: true,
        casa_org_id: organization.id,
        password: nil
      )
    end

    it "sends an invite from the user" do
      admin = CreateCasaAdminService.new(organization, params, user)
      admin.build

      casa_admin = admin.create!

      expect(casa_admin.invited_by_id).to eq(user.id)
      expect(casa_admin.invited_by_type).to eq("User")
    end

    context "when there are errors" do
      it "does not create the CasaAdmin and returns the errors" do
        params = ActionController::Parameters.new(
          {
            casa_admin: {
              email: "invalid_email_format",
              display_name: "Bob Cat"
            }
          }
        ).permit!

        admin = CreateCasaAdminService.new(organization, params, user)
        admin.build

        expect do
          admin.create!
        end.to raise_error(ActiveRecord::RecordInvalid, /email is invalid/i)
      end
    end
  end
end
