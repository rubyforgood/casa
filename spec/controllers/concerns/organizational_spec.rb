require "rails_helper"

class MockController < ApplicationController
  include Organizational
end

RSpec.describe MockController, type: :controller do
  it "raises a UnknownOrganization error" do
    expect { controller.require_organization! }.to raise_error(Organizational::UnknownOrganization)
  end

  it "does not raise a UnknownOrganization error" do
    current_user = create(:volunteer)

    allow(controller).to receive(:current_user).and_return(current_user)

    expect { controller.require_organization! }.not_to raise_error
  end

  it "returns the user's current organization" do
    current_user = create(:volunteer)

    allow(controller).to receive(:current_user).and_return(current_user)

    expect(controller.current_organization).to eq(current_user.casa_org)
  end

  context "when admin" do
    it "returns the current user role" do
      current_user = create(:all_casa_admin)

      allow(controller).to receive(:current_user).and_return(current_user)

      expect(controller.current_role).to eq(current_user.role)
    end
  end

  context "when admin" do
    it "returns the current user role" do
      current_user = create(:all_casa_admin)

      allow(controller).to receive(:current_user).and_return(current_user)

      expect(controller.current_role).to eq(current_user.role)
    end
  end

  context "when supervisor" do
    it "returns the current user role" do
      current_user = create(:supervisor)

      allow(controller).to receive(:current_user).and_return(current_user)

      expect(controller.current_role).to eq(current_user.role)
    end
  end

  context "when volunteer" do
    it "returns the current user role" do
      current_user = create(:volunteer)

      allow(controller).to receive(:current_user).and_return(current_user)

      expect(controller.current_role).to eq(current_user.role)
    end
  end
end
